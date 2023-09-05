
module Db (sqlfn) where

import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BSC
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.SqlQQ
-- import Config

import Database.PostgreSQL.Simple

connectionInfo :: ConnectInfo
connectionInfo = defaultConnectInfo
    { connectHost = "localhost"
    , connectPort = 5432
    , connectUser = "postgres"
    , connectPassword = "root"
    , connectDatabase = "mydbq"
    }

executeSqlFile :: Connection -> FilePath -> IO ()
executeSqlFile conn filePath = do
    -- Read the SQL file
    sqlFileContents <- BS.readFile filePath
    -- Execute the SQL queries from the file
    execute_ conn $ fromString (BSC.unpack sqlFileContents)
    return ()



sqlfn :: IO ()
sqlfn = do
    -- Establish a database connection
    conn <- connect connectionInfo
    executeSqlFile conn "/Users/suraj.kumar1/Desktop/proj/pragati/backend/src/abc.sql"
    -- Close the database connection
    close conn
