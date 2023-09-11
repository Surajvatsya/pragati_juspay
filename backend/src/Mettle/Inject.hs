{-# OPTIONS_GHC -Wno-deprecations #-}
module Mettle.Inject where
import qualified Data.ByteString.Builder                as BB
import qualified Data.ByteString.Char8                  as C
import qualified Data.ByteString.Lazy                   as BSL
import qualified Data.CaseInsensitive                   as CI
import qualified Data.HashMap.Strict                    as HM
import qualified Data.Text                              as T
import qualified Data.Text.Encoding                     as E
import qualified Data.Vault.Lazy                        as V
import qualified Database.Beam                          as B
import           EulerHS.Language                       as Lang
import           EulerHS.Prelude                        as EP
-- import qualified Mettle.Config                          as Config
-- import qualified Mettle.Environment                     as ENV
-- import qualified Mettle.Product.Auth.ValidateToken      as AuthValidateToken
-- import qualified Mettle.Services.DB.EmployeeQueries     as EmployeeQueries
-- import qualified Mettle.Types.API.GraphQL.DepthResolver as DepthResolverGraphQLAPI
-- import qualified Mettle.Types.API.GraphQL.Employee      as EmployeeGraphQLAPI
-- import qualified Mettle.Types.API.Users                 as UsersAPI
-- import           Mettle.Types.DB.DB                     as DB
-- import qualified Mettle.Types.DB.Employee               as DBEmployee
-- import qualified Mettle.Types.DB.EmployeeRTeam          as DBEmployeeRTeam
-- import qualified Mettle.Types.Engineering               as API
-- import qualified Mettle.Utils.DB.Accessor               as Acc
-- import qualified Mettle.Utils.DB.Queries                as Q
-- import           Mettle.Utils.FlowMonad                 as L
-- import           Mettle.Utils.Logger.Logger             as Logger (logAPIDebug)
import           Network.Wai                            as N
import           Network.Wai.Middleware.Cors            (CorsResourcePolicy (..),
                                                         cors)

addHeadersToVault :: V.Key (HashMap Text Text) -> N.Application -> N.Application
addHeadersToVault key baseApp =
  \req respFunc -> do
    let rawUrl = E.decodeUtf8 $ rawPathInfo req
    (req', rawBodyArr) <- getRequestBody req
    let rawBody = foldMap E.decodeUtf8 rawBodyArr
    baseApp (addHeaders req' rawBody rawUrl) respFunc
  where
    addHeaders :: Request -> Text -> Text -> Request
    addHeaders req rawBody rawUrl = do
      let t =
            HM.fromList $
            (\h ->
               (T.toLower . E.decodeUtf8 . CI.original . fst $ h, E.decodeUtf8 . snd $ h)) <$>
            requestHeaders req
          t' = (.) (HM.insert "x-raw-body" rawBody) (HM.insert "x-raw-url" rawUrl) t
      req {vault = V.insert key t' (N.vault req)}

getRequestBody :: Request -> IO (Request, [C.ByteString])
getRequestBody req = do
  body <- readBodyFromStream id
  ichunks <- newIORef body
  let rbody =
        atomicModifyIORef ichunks $ \case
          []  -> ([], C.empty)
          x:y -> (y, x)
  let req' = req {requestBody = rbody}
  return (req', body)
  where
    readBodyFromStream front = do
      bs <- N.getRequestBodyChunk req
      if C.null bs
        then return $ front []
        else readBodyFromStream $ front . (bs :)