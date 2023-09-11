module Mettle.ErrorResponse  where

import qualified Data.Aeson                            as A
import qualified Data.ByteString.Lazy                  as LB
import           EulerHS.Prelude
import qualified Mettle.Inject          as MI
import           Mettle.APIErrorCode         (badRequest,
                                                        requestFailed)
import           Network.Wai
-- import           Network.Wai.Middleware.Servant.Errors
import           Servant
import           System.IO.Unsafe

data MettleErrType a

-- instance Accept (MettleErrType JSON) where
--   contentType _ = contentType (Proxy @JSON)

-- instance HasErrorBody (MettleErrType JSON) '[] where
--   encodeError = encodeMettleErr

-- customErrorMW :: Middleware
-- customErrorMW baseApp req respFunc = do
--     (req', _) <- MI.getRequestBody req
--     let respF = errorMw @(MettleErrType JSON) @'[] $ baseApp
--     respF req' respFunc

-- encodeMettleErr :: StatusCode -> ErrorMsg -> LB.ByteString
-- encodeMettleErr code content = unsafePerformIO $ do
--   let _ = content
--   return $
--       case unStatusCode code of
--         400 -> A.encode $ badRequest (unErrorMsg content)
--         _   -> A.encode $ requestFailed (unErrorMsg content)

-- module Mettle.ErrorResponse (customErrorMW) where

-- import Data.Aeson                            as A
-- import qualified Data.ByteString.Lazy                  as LB
-- import           EulerHS.Prelude
-- import qualified Mettle.Inject          as MI
-- import           Mettle.APIErrorCode         (badRequest,
--                                                         requestFailed)
-- import           Network.Wai
-- import           Servant
-- import           System.IO.Unsafe
-- import           Control.Exception (SomeException)
-- import Network.HTTP.Types.Status

-- data MettleErrType a

-- instance Accept (MettleErrType JSON) where
--   contentType _ = contentType (Proxy @JSON)

-- -- Define your custom error data type
-- data CustomError = CustomError
--     { errorCode :: Int
--     , errorMessage :: Text
--     }

-- instance ToJSON CustomError where
--     toJSON (CustomError code message) =
--         A.object [ "code" .= code, "message" .= message ]

-- customErrorMW :: Middleware
-- customErrorMW baseApp req respFunc = do
--     (req', _) <- MI.getRequestBody req
--     -- Catch exceptions and handle them
--     result <- try (baseApp req')
--     case result of
--         Left (e :: SomeException) -> handleException e respFunc
--         Right response -> respFunc response

-- -- Handle exceptions and generate custom error responses
-- handleException :: SomeException -> (Response -> IO ResponseReceived) -> IO ResponseReceived
-- handleException e respFunc =
--     let customError = CustomError 500 "Internal Server Error" in
--     respFunc $ responseLBS
--         status500
--         [ ("Content-Type", "application/json") ]
--         (A.encode customError)
