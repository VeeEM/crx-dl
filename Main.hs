{-# LANGUAGE OverloadedStrings #-}
module Main where

import qualified Network.HTTP.Client as HTTP
import qualified Network.HTTP.Client.TLS as HTTP
import qualified Network.HTTP.Types.Header as HTTP
import qualified Data.ByteString.Lazy as BSL
import System.Environment

getWithUserAgent :: String -> IO (HTTP.Response BSL.ByteString)
getWithUserAgent url = do
    manager <- HTTP.newManager HTTP.tlsManagerSettings
    req <- HTTP.parseRequest url
    let request = req {
        HTTP.requestHeaders = (HTTP.hUserAgent, "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36") : []
    }
    HTTP.httpLbs request manager

dlUrl :: String -> String -> String
dlUrl prodver extid = "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=" ++ prodver  ++ "&acceptformat=crx3" ++ "&x=id%3D" ++ extid ++ "%26uc"

main :: IO ()
main = do
  arg <- head <$> getArgs
  if length arg /= 32
     then putStrLn "Extension id must be 32 characters long."
     else do
       response <- getWithUserAgent $ dlUrl "83.0.4103.116" arg
       BSL.writeFile (arg ++ ".crx") (HTTP.responseBody response)
