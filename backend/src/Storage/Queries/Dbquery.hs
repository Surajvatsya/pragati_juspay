{-# LANGUAGE BangPatterns      #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-redundant-constraints #-}
{-# OPTIONS_GHC -Wno-missing-export-lists #-}
{-# OPTIONS_GHC -Wno-name-shadowing #-}
{-# OPTIONS_GHC -Wno-unused-matches #-}
{-# OPTIONS_GHC -Wno-missing-signatures #-}
module Storage.Queries.Dbquery where

-- module Mettle.Utils.DB.Queries where

import           Control.Lens.Getter            (Getting)
import qualified Data.Aeson as A
import qualified Data.Aeson                     as A
-- import           Data.Scientific
import qualified Data.Text                      as DT
import qualified Database.Beam                  as B
import qualified Database.Beam.Postgres         as BP
import qualified Database.Beam.Query.Internal   as B
import           Database.Beam.Schema.Tables
import           EulerHS.Prelude
import qualified EulerHS.Types                  as T
import qualified Servant                        as S
import Storage.Queries.Config
import qualified Storage.Queries.PostgresConfig as DB
import qualified Storage.Queries.FlowMonad      as L

runWithArtCheck ::
     ( T.BeamRunner beM, beM ~ BP.Pg)
  =>T.SqlConn beM
  -> L.SqlDB beM a
  -> L.Flow (T.DBResult a)
runWithArtCheck conn query = do
  -- AppState {..} <- ask
  L.runDB conn query

runR ::
     ( FromJSON a
     , T.BeamRunner beM
     , beM ~ BP.Pg
     , B.Beamable table
     , B.Database be db
     )
  => B.DatabaseEntity be db (B.TableEntity table)
  -> L.SqlDB beM a
  -> L.Flow (T.DBResult a)
runR dbTable query = do
  config <- L.getConfig
  loggerRuntime <- L.getLoggerRuntime
  -- (dbMachineIdx, dbType) <- findDBMachine dbTable config METTLEDB
  postgresReadDBConfig <-
    DB.getPGConfig
      DB.TX
      "read"
      1
      config
  conn <- DB.getOrInitConn postgresReadDBConfig False loggerRuntime
  runWithArtCheck conn query

findOne ::
     ( ToJSON (table Identity)
     , FromJSON (table Identity)
     , B.Beamable table
     , B.Database be db
     , B.FromBackendRow be (table Identity)
     , be ~ BP.Postgres
     )
  => B.DatabaseEntity be db (B.TableEntity table)
  -> (table (B.QExpr be (B.QNested B.QBaseScope)) -> B.QExpr be (B.QNested B.QBaseScope) B.SqlBool)
  -> L.Flow (T.DBResult (Maybe (table Identity)))
findOne dbTable predicate = runR dbTable (findOne' dbTable predicate)

findOne' ::
     ( B.Beamable table
     , B.Database be db
     , B.FromBackendRow be (table Identity)
     , be ~ BP.Postgres
     , beM ~ BP.Pg
     )
  => B.DatabaseEntity be db (B.TableEntity table)
  -> (table (B.QExpr be (B.QNested B.QBaseScope)) -> B.QExpr be (B.QNested B.QBaseScope) B.SqlBool)
  -> L.SqlDB beM (Maybe (table Identity))
findOne' dbTable predicate = do
  rows <- L.findRows $ B.select $ B.limit_ 1 $ B.filter_' predicate $ B.all_ dbTable
  return $ headMaybe rows

headMaybe :: [a] -> Maybe a
headMaybe []    = Nothing
headMaybe (a:_) = Just a





