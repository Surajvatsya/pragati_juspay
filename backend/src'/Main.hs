

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}

module Main where

-- import Lib

import Prelude 
-- import Prelude.Compat
import Db

import Control.Monad.Except
import Control.Monad.Reader
import qualified Data.Aeson as A
import qualified Data.Aeson.Types as DAT
-- import Data.Attoparsec.ByteString
import Data.ByteString (ByteString)
import Data.List
import Data.Maybe
-- import Data.String.Conversions
import Data.Time.Calendar
import GHC.Generics
-- import Lucid
-- import Network.HTTP.Media ((//), (/:))
-- import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import System.Directory
-- import Text.Blaze
-- import Text.Blaze.Html.Renderer.Utf8
-- import Servant.Types.SourceT (source)
import qualified Data.Aeson.Parser as AP
-- import qualified Text.Blaze.Html

-- main :: IO ()
-- main = do
--   print "hello world"


type UserAPI1 = "users" :> Get '[JSON] [User]

data User = User
  { name :: String
  , age :: Int
  , email :: String
  , registration_date :: Day
  } deriving (Eq, Show, Generic)

instance ToJSON User


users1 :: [User]
users1 =
  [ User "Isaac Newton"    372 "isaac@newton.co.uk" (fromGregorian 1683  3 1)
  , User "Albert Einstein" 136 "ae@mc2.org"         (fromGregorian 1905 12 1)
  ]


server1 :: Server UserAPI1
server1 = return users1


userAPI :: Proxy UserAPI1
userAPI = Proxy

-- 'serve' comes from servant and hands you a WAI Application,
-- which you can think of as an "abstract" web application,
-- not yet a webserver.
app1 :: Application
app1 = serve userAPI server1



main :: IO ()
main = do
  sqlfn
  run 8081 app1
