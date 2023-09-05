module Server (startPragati) where

import qualified API.UI.CheckDuplicate as AU
import qualified Domain.Action.UI.CheckDuplicate as DAU
import Domain.Types.Candidate
import Network.Wai.Handler.Warp (run)
import Servant.API
import Servant.Server
-- import SharedLogic.Migration


startPragati :: IO ()
startPragati = run 8000 (serve AU.usersApi server)


server :: Server AU.API
server =
  DAU.checkDuplicate
    -- :<|> DAU.postUserHandler
    -- :<|> DAU.updateUserHandler
    -- :<|> DAU.deleteUserById

-- runServer :: IO ()
-- runServer = run 8000 (serve AU.usersApi server)