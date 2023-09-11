module Storage.Queries.FlowMonad
  ( module X
  , Flow
  , Storage.Queries.FlowMonad.getConfig
  , getLoggerRuntime
  , AppState (..)
  ) where

import           EulerHS.Language         as X hiding (Flow, logInfo,getConfig)
import           EulerHS.Prelude
import qualified EulerHS.Runtime          as R
-- import GHC.TypeLits
import qualified Storage.Queries.Config           as C
-- import           Mettle.Types.Engineering (AppState (..))

data AppState = AppState
  { config      :: C.Config
  , runTime     :: !R.FlowRuntime
  , channelName :: !ByteString
  }

type Flow = X.ReaderFlow AppState

getConfig :: Flow C.Config
getConfig = do
  AppState {..} <- ask
  return config

getLoggerRuntime :: Flow R.LoggerRuntime
getLoggerRuntime = do
  AppState {..} <- ask
  return $ R._loggerRuntime $ R._coreRuntime runTime
