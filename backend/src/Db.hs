
module Db (sqlfn) where

-- import qualified Data.ByteString as BS
-- import qualified Data.ByteString.Char8 as BSC
-- import Database.PostgreSQL.Simple
-- -- import Config

-- import Database.PostgreSQL.Simple

-- connectionInfo :: ConnectInfo
-- connectionInfo = defaultConnectInfo
--     { connectHost = "localhost"
--     , connectPort = 5432
--     , connectUser = "postgres"
--     , connectPassword = "root"
--     , connectDatabase = "mydb"
--     }



-- sqlfn :: IO ()
-- sqlfn = do
--     -- Read the SQL file
--     sqlFileContents <- BS.readFile "/Users/suraj.kumar1/Desktop/proj/pragati/backend/src/abc.sql"

--     -- Establish a database connection
--     conn <- connect connectionInfo

--     -- Execute the SQL queries from the file
--     execute_ conn (BSC.unpack sqlFileContents)

--     -- Close the database connection
--     close conn
