module Mettle.APIErrorCode where

import           EulerHS.Prelude
import  Data.Aeson as A
import qualified Storage.Beam.Utils as SBU
-- import PragatiServer
-- import           Mettle.Types.Engineering


-- genericErrorResponse :: Text -> Text -> Text -> Maybe Text -> ErrorResponse
-- genericErrorResponse status responseCode responseMessage payload =
--   ErrorResponse
--     { _status = status
--     , _responseCode = responseCode
--     , _responseMessage = responseMessage
--     , _payload = payload
--     }

-- genericFailureResponse :: Text -> ErrorResponse
-- genericFailureResponse message =
--   genericErrorResponse
--     "FAILURE"
--     "500"
--     message
--     Nothing

-- serviceUnavailable :: Text -> Maybe Text -> ErrorResponse
-- serviceUnavailable service code =
--   genericErrorResponse
--     "FAILURE"
--     ("SERVICE_UNAVAILABLE" <> "_" <> service <> "_" <> fromMaybe "NA" code)
--     (service <> " service is not reachable at the moment (" <> fromMaybe "NA" code <> ")")
--     Nothing


-- invalidData :: Text -> ErrorResponse
-- invalidData msg =
--   genericErrorResponse
--     "FAILURE"
--     "INVALID_DATA"
--     msg
--     Nothing

-- internalServerErr :: ErrorResponse
-- internalServerErr =
--   genericErrorResponse
--     "FAILURE"
--     "INTERNAL_SERVER_ERROR"
--     "INTERNAL_SERVER_ERROR"
--     Nothing

-- serviceUnavailable' :: ErrorResponse
-- serviceUnavailable' =
--   ErrorResponse
--     { _status = "FAILURE"
--     , _responseCode = "SERVICE_UNAVAILABLE"
--     , _responseMessage = "Mettle service is not reachable at the moment"
--     , _payload = Nothing
--     }

-- serviceUnavailableTransaction :: Text -> Maybe Text -> ErrorResponse
-- serviceUnavailableTransaction service code =
--   ErrorResponse
--     { _status = "FAILURE"
--     , _responseCode = "SERVICE_UNAVAILABLE" <> "_" <> service <> "_" <> fromMaybe "NA" code
--     , _responseMessage = "Mettle service is not reachable at the moment for transactional apis"
--     , _payload = Nothing
--     }

-- successResp :: ErrorResponse
-- successResp =
--   ErrorResponse
--     { _status = "SUCCESS"
--     , _responseCode = "SUCCESS"
--     , _responseMessage = "SUCCESS"
--     , _payload = Nothing
--     }


-- duplicateRequest :: ErrorResponse
-- duplicateRequest =
--   ErrorResponse
--     { _status = "FAILURE"
--     , _responseCode = "DUPLICATE_REQUEST"
--     , _responseMessage = "DUPLICATE_REQUEST"
--     , _payload = Nothing
--     }


badRequest :: Text -> ErrorResponse
badRequest msg =
  ErrorResponse
    { _status = "FAILURE"
    , _responseCode = "BAD_REQUEST"
    , _responseMessage = msg
    , _payload = Nothing
    }

-- requestExpired :: ErrorResponse
-- requestExpired =
--   ErrorResponse
--     { _status = "FAILURE"
--     , _responseCode = "REQUEST_EXPIRED"
--     , _responseMessage = "REQUEST_EXPIRED"
--     , _payload = Nothing
--     }

-- sessionExpired :: ErrorResponse
-- sessionExpired =
--   ErrorResponse
--     { _status = "FAILURE"
--     , _responseCode = "SESSION_EXPIRED"
--     , _responseMessage = "SESSION_EXPIRED"
--     , _payload = Nothing
--     }

-- unauthorized :: ErrorResponse
-- unauthorized =
--   ErrorResponse
--     { _status = "FAILURE"
--     , _responseCode = "UNAUTHORIZED"
--     , _responseMessage = "UNAUTHORIZED"
--     , _payload = Nothing
--     }

-- requestNotFound :: ErrorResponse
-- requestNotFound =
--   ErrorResponse
--     { _status = "FAILURE"
--     , _responseCode = "REQUEST_NOT_FOUND"
--     , _responseMessage = "REQUEST_NOT_FOUND"
--     , _payload = Nothing
--     }

-- originalRecordNotFound :: ErrorResponse
-- originalRecordNotFound =
--   ErrorResponse
--     { _status = "FAILURE"
--     , _responseCode = "INVALID_DATA"
--     , _responseMessage = "Original record not found"
--     , _payload = Nothing
--     }

-- -- invalidMerchant :: ErrorResponse
-- -- invalidMerchant =
-- --   ErrorResponse
-- --     { _status = "FAILURE"
-- --     , _responseCode = "INVALID_MERCHANT"
-- --     , _responseMessage = "INVALID_MERCHANT"
-- --     , _payload = Nothing
-- --     }

requestFailed :: Text -> ErrorResponse
requestFailed msg =
  ErrorResponse
    { _status = "FAILURE"
    , _responseCode = "REQUEST_FAILED"
    , _responseMessage = msg
    , _payload = Nothing
    }

-- requestPending :: ErrorResponse
-- requestPending =
--   ErrorResponse
--     { _status = "FAILURE"
--     , _responseCode = "REQUEST_PENDING"
--     , _responseMessage = "REQUEST_PENDING"
--     , _payload = Nothing
--     }

-- createNewConfigDraftFailed :: ErrorResponse
-- createNewConfigDraftFailed =
--   ErrorResponse
--     { _status = "FAILURE"
--     , _responseCode = "ERR_CREATE_DRAFT"
--     , _responseMessage = "Could not create a new draft. Please try again"
--     , _payload = Nothing
--     }

genericErrorResponse :: Text -> Text -> Text -> Maybe Text -> ErrorResponse
genericErrorResponse status responseCode responseMessage payload =
  ErrorResponse
    { _status = status
    , _responseCode = responseCode
    , _responseMessage = responseMessage
    , _payload = payload
    }

internalServerErr :: ErrorResponse
internalServerErr =
  genericErrorResponse
    "FAILURE"
    "INTERNAL_SERVER_ERROR"
    "INTERNAL_SERVER_ERROR"
    Nothing


data ErrorResponse = ErrorResponse
  { _status          :: Text
  , _responseCode    :: Text
  , _responseMessage :: Text
  , _payload         :: Maybe Text
  }
  deriving (Show, Generic)

instance Exception ErrorResponse

instance FromJSON ErrorResponse where
  parseJSON = genericParseJSON SBU.stripAllLensPrefixOptions

instance ToJSON ErrorResponse where
  toJSON =
    genericToJSON
      (SBU.stripAllLensPrefixOptions {omitNothingFields = True})