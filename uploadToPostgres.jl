using LibPQ
using Dates

# Connection parameters – override via environment variables if needed
const PG_HOST = get(ENV, "PG_HOST", "marcus.ace.chalmers.se")
const PG_USER = get(ENV, "PG_USER", "postgres")
const PG_PASSWORD = get(ENV, "PG_PASSWORD", "naannaan")
const PG_DBNAME = get(ENV, "PG_DBNAME", "postdofs")

"""
    ensure_table(conn)

Create the `luna_data` table if it does not already exist.
Each row represents one averaged acquisition cycle:
  - recorded_at : timestamp of the acquisition
  - file_number : the rolling JLD2 file index
  - ch1..ch8    : spatial measurement arrays (one value per sensing point)
"""
function ensure_table(conn)
    execute(
        conn,
        """
    CREATE TABLE IF NOT EXISTS luna_data (
        id          SERIAL PRIMARY KEY,
        recorded_at TIMESTAMP NOT NULL,
        file_number INTEGER   NOT NULL,
        ch1         DOUBLE PRECISION[],
        ch2         DOUBLE PRECISION[],
        ch3         DOUBLE PRECISION[],
        ch4         DOUBLE PRECISION[],
        ch5         DOUBLE PRECISION[],
        ch6         DOUBLE PRECISION[],
        ch7         DOUBLE PRECISION[],
        ch8         DOUBLE PRECISION[]
    );
"""
    )
end

"""
    uploadToPostgres(data, timeF, file_number, j_map)

Upload one acquisition row to the PostgreSQL database.

# Arguments
- `data`        : `MyStruct` holding the freshly acquired (filtered, averaged) channel matrices
- `timeF`       : `DateTime` timestamp for this acquisition
- `file_number` : current rolling file index `n`
- `j_map`       : `Dict(1 => :ch1, …, 8 => :ch8)`
"""
function uploadToPostgres(data, timeF, file_number, j_map)
    conn_str = "host=$(PG_HOST) user=$(PG_USER) password=$(PG_PASSWORD) dbname=$(PG_DBNAME)"
    conn = LibPQ.Connection(conn_str)
    try
        ensure_table(conn)

        # Extract each channel as a plain Vector{Float64} (drop the row dimension).
        # If a channel was never populated this cycle, store NULL rather than an
        # empty array so it is easy to detect missing data on the DB side.
        channels = map(1:8) do i
            v = vec(getfield(data, j_map[i]))
            isempty(v) ? nothing : v
        end

        execute(conn,
            """
            INSERT INTO luna_data
                (recorded_at, file_number, ch1, ch2, ch3, ch4, ch5, ch6, ch7, ch8)
            VALUES
                (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10)
            """,
            [timeF, file_number,
                channels[1], channels[2], channels[3], channels[4],
                channels[5], channels[6], channels[7], channels[8]]
        )
        println("PostgreSQL upload successful for file ", file_number, " at ", timeF)
    catch e
        @warn "PostgreSQL upload failed: " exception = e
    finally
        close(conn)
    end
end
