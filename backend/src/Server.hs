module Server (startServer) where

import qualified API.UI.CheckDuplicate as AU
import qualified Domain.Action.UI.CheckDuplicate as DAU
import Domain.Types.Candidate
import Network.Wai.Handler.Warp (run, Settings, defaultSettings,runSettings, setFork,setOnExceptionResponse, setPort)
import Servant.API
import Servant.Server
import qualified Storage.Queries.FlowMonad            as L
-- import SharedLogic.Migration
import Control.Monad.Except
import Control.Monad.Trans.Except (ExceptT(..), runExceptT)
-- import qualified Storage.Queries.FlowMonad            as L
import qualified Data.Vault.Lazy                     as V
import           EulerHS.Runtime                     as R
import qualified Network.HTTP.Types             as H
import           Network.Wai.Middleware.Cors            (CorsResourcePolicy (..),
                                                         cors)
import EulerHS.Prelude
import           Network.Wai
import qualified Mettle.ErrorResponse as ERM
import qualified Mettle.Inject        as M
import qualified Storage.Beam.Utils as SBU

-- type FlowServer
--   = ServerT AU.API (ReaderT L.AppState (ExceptT ServerError IO))

-- mettleCors :: Middleware
-- mettleCors = cors (const $ Just
--   CorsResourcePolicy
--     { corsOrigins = Nothing
--     , corsMethods = ["GET", "HEAD", "POST", "OPTIONS", "PUT", "PATCH", "DELETE"]
--     , corsRequestHeaders =
--       [ "Accept"
--       , "Accept-Language"
--       , "Content-Language"
--       , "Authorization"
--       , "Content-Type"
--       , "Cache-Control"
--       , "Access-Control-Request-Headers"
--       , "Access-Control-Request-Method"
--       , "Origin"
--       , "mettle-token"
--       ]
--     , corsExposedHeaders = Nothing
--     , corsMaxAge = Nothing
--     , corsVaryOrigin = False
--     , corsRequireOrigin = False
--     , corsIgnoreFailures = True
--     }
--   )


-- run :: V.Key (HashMap Text Text) -> L.AppState -> Application
-- run  key env = mettleCors $ ERM.customErrorMW $ M.addHeadersToVault
--   key
--   (serve AU.pragatiAPIs $ pragatiServer env key)




startServer :: IO ()
startServer = run 8000 (serve AU.pragatiAPIs pragatiServer)


-- server :: Server AU.API
-- server = checkDuplicateHandler

-- checkDuplicateHandler :: DAU.CheckDuplicateReq -> Handler Candidate
-- checkDuplicateHandler req = do
--   -- Call DAU.checkDuplicate and handle the result
--   -- res <- liftIO $ L.runFlow $ DAU.checkDuplicate req
--   result <- liftIO $ runExceptT $ DAU.checkDuplicate req
--   case res of
--     Left errMsg -> throwError $ err400 { errBody = errMsg }
--     Right candidate -> return candidate


pragatiServer :: Server AU.API
pragatiServer = xyz

xyz :: DAU.CheckDuplicateReq -> Handler [Candidate] 
xyz = DAU.checkDuplicate

-- pragatiServer :: L.AppState -> V.Key (HashMap Text Text) -> Server AU.API
-- pragatiServer env key = hoistServer AU.pragatiAPIs  f (mettleServer' key)
--  where
--   f :: ReaderT L.AppState (ExceptT ServerError IO) a -> Handler a
--   f r = do
--     optionsVar <- liftIO $ newMVar mempty
--     let env' = env { L.runTime = (L.runTime env) { R._options = optionsVar } }
--     eResult <- liftIO $ runExceptT $ runReaderT r env'
--     case eResult of
--       Left err -> do
--         print (("exception thrown: " :: [Char]) <> show err) *> throwError err
--       Right res -> pure res

-- mettleServer' :: V.Key (HashMap Text Text) ->  FlowServer
-- mettleServer' =
--   AU.checkDuplicateCandidateHandler