{-# OPTIONS_GHC -Wno-incomplete-uni-patterns #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use head" #-}
{-# OPTIONS_GHC -Wno-name-shadowing #-}

module Storage.Beam.Utils
( commonFieldModifier
, Storage.Beam.Utils.stripLensPrefixOptions
, Storage.Beam.Utils.stripAllLensPrefixOptions
, replaceUnderscoreWithHyphen
, stripAllLensPrefixAndUnderscoreOptions
, dropUnderscoreReplacet
, forkIOWithUnmaskLabel
, convertTextToInt
-- , getNextMinorVersion
-- , getNextMajorVersion
, getNow
, formatTime
, nullVectorToNothing
, nullStringToNothing
, nullTextToNothing
-- , valueToMapConverter
, toLowerCase
, emptyList
, nonPositiveToNothingConverter
, addRedisKeyPrefix
, valueToTextConverter
, valueToStringConverter
, merge
, convertTextToLocalTime
, formatMaybeTime
) where


import           Data.Aeson          as A
import qualified Data.HashMap.Strict as HM
import qualified Data.Map            as MP
import qualified Data.Text           as T
import           Data.Time           (LocalTime, TimeZone (TimeZone),
                                      ZonedTime (zonedTimeToLocalTime),
                                      getCurrentTime, utcToZonedTime)
import qualified Data.Time           as DT
import qualified Data.Time.Format    as FT (defaultTimeLocale, formatTime)
import qualified Data.Vector         as VT
import           EulerHS.Prelude     as EP hiding (null, head )
import           GHC.Conc
-- import Prelude ()

commonFieldModifier :: String -> String
commonFieldModifier "_type"                = "type"
commonFieldModifier "_default"             = "default"
commonFieldModifier "_data"                = "data"
commonFieldModifier "_MerchantId"          = "MerchantId"
commonFieldModifier "_CustomerId"          = "CustomerId"
commonFieldModifier "_DeviceId"            = "DeviceId"
commonFieldModifier "_TransactionId"       = "TransactionId"
commonFieldModifier "_ParentMerchantId"    = "ParentMerchantId"
commonFieldModifier "CALLBACK_SUCCESS"     = "SUCCESS"
commonFieldModifier "CALLBACK_FAILURE"     = "FAILURE"
commonFieldModifier "CALLBACK_PENDING"     = "PENDING"
commonFieldModifier "CALLBACK_UNINITIATED" = "UNINITIATED"
commonFieldModifier "CALLBACK_DEEMED"      = "DEEMED"
commonFieldModifier "RESP_SUCCESS"         = "SUCCESS"
commonFieldModifier "RESP_FAILURE"         = "FAILURE"
commonFieldModifier name                   = name

stripLensPrefixOptions :: Options
stripLensPrefixOptions = defaultOptions {fieldLabelModifier = drop 1}

stripAllLensPrefixOptions :: Options
stripAllLensPrefixOptions = defaultOptions {fieldLabelModifier = dropPrefix}
  where
    dropPrefix :: String -> String
    dropPrefix = dropWhileAdjacentEqual
    
    dropWhileAdjacentEqual :: String -> String
    dropWhileAdjacentEqual [] = []
    dropWhileAdjacentEqual (x:xs@(y:_))
      | x == y = dropWhileAdjacentEqual xs
    dropWhileAdjacentEqual xs = xs
    -- dropPrefix :: String -> String
    -- dropPrefix [] = []
    -- dropPrefix (x:xs)
    --   | x == head xs = dropPrefix xs
    --   | otherwise = x:xs
  -- where
  --   dropPrefix :: String -> String
  --   dropPrefix field =
  --     if not (null field)
  --       then dropWhile (== head field) field
  --       else field

replaceUnderscoreWithHyphen :: String -> String
replaceUnderscoreWithHyphen =
  T.unpack . T.replace "_" "-" . T.pack . dropWhile (== '_')

stripAllLensPrefixAndUnderscoreOptions :: Options
stripAllLensPrefixAndUnderscoreOptions = defaultOptions {fieldLabelModifier = replaceUnderscoreWithHyphen}

dropUnderscoreReplacet :: String -> String
dropUnderscoreReplacet field = do
  let a = dropWhile (== '_') field
  if a == "t" then "$t" else a


forkIOWithUnmaskLabel :: String -> ((forall a. IO a -> IO a) -> IO ()) -> IO ThreadId
forkIOWithUnmaskLabel label f = do
  tid <- forkIOWithUnmask f
  labelThread tid label
  return tid

convertTextToInt :: Text -> Int
convertTextToInt t = let (i, _): _ = (reads $ T.unpack t :: [(Int, String)]) in i

-- getNextMinorVersion :: Text -> Text
-- getNextMinorVersion v =
--   let s = T.splitOn "." v
--       newMinorVersion = T.pack . show . succ . convertTextToInt $ (s !! 1)
--   in (s !! 0) <> T.singleton '.' <> newMinorVersion

-- getNextMajorVersion :: Text -> Text
-- getNextMajorVersion v =
--   let s = T.splitOn "." v
--       newMajorVersion = T.pack . show . succ . convertTextToInt $ (s !! 0)
--   in newMajorVersion <> T.pack ".0"


getNow :: IO LocalTime
getNow = zonedTimeToLocalTime . utcToZonedTime ist <$> getCurrentTime

ist :: TimeZone
ist = TimeZone 330 False "IST"

formatTime :: LocalTime -> Text
formatTime time = T.pack $ FT.formatTime FT.defaultTimeLocale "%m-%d-%Y %I:%M %p" time

formatMaybeTime :: Maybe LocalTime -> Maybe Text
formatMaybeTime time = case time of
  Nothing -> Nothing
  Just x -> Just $ T.pack $ FT.formatTime FT.defaultTimeLocale "%m-%d-%Y %I:%M %p" x

nullVectorToNothing::Maybe (Vector Text) -> Maybe (Vector Text)
nullVectorToNothing value=if VT.null (fromMaybe VT.empty value) then Nothing else value

nullStringToNothing :: Maybe String -> Maybe String
nullStringToNothing value=if  fromMaybe "" value == "" then Nothing else value

nullTextToNothing :: Maybe Text -> Maybe Text
nullTextToNothing value=if  fromMaybe "" value == "" then Nothing else value

-- valueToMapConverter :: Value -> MP.Map String (Maybe Value)
-- valueToMapConverter (Object m) = (MP.fromList . EP.map f) (HM.toList m)
--     where f (x, y) = (T.unpack x, Just y)
-- valueToMapConverter _ = MP.empty

valueToTextConverter :: Maybe Value -> Text
valueToTextConverter (Just (String m)) = m
valueToTextConverter _                 = ""

valueToStringConverter :: Maybe Value -> String
valueToStringConverter (Just (A.Number m)) = show m
valueToStringConverter _                 = ""

toLowerCase :: String -> String
toLowerCase = T.unpack . T.toLower . T.pack

emptyList :: [a]
emptyList=[]

nonPositiveToNothingConverter :: Int -> Maybe Int
nonPositiveToNothingConverter value
      | value <= 0 = Nothing
      | otherwise = Just value

addRedisKeyPrefix :: Text -> Text
addRedisKeyPrefix key = T.append "mettle_" key

merge :: [a] -> [a] -> [a]
merge xs     []     = xs
merge []     ys     = ys
merge (x:xs) (y:ys) = x : y : merge xs ys

convertTextToLocalTime :: Maybe Text -> Maybe LocalTime
convertTextToLocalTime time = do
  case time of
    Nothing -> Nothing
    Just x -> DT.parseTimeM True DT.defaultTimeLocale "%Y-%m-%dT%H:%M:%S" (T.unpack x) :: Maybe DT.LocalTime
