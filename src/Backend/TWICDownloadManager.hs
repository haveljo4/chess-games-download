module Backend.TWICDownloadManager (downloadAndGroup) where
import System.Directory (createDirectoryIfMissing, removeDirectoryRecursive)
import System.FilePath ((</>))
import Control.Monad (forM_)
import Codec.Archive.Zip
import Conduit
import qualified Data.Conduit.Combinators as CC
import qualified Data.ByteString as BS
import qualified Backend.Downloader as Downloader
import qualified Backend.PGNFileConcatenator as PGNFileConcatenator
import qualified Data.Text as T


downloadAndGroup :: Integer -> Integer -> FilePath -> (String -> String -> IO ()) -> IO ()
downloadAndGroup iFrom iTo outputFolder logFunction = do
    let tmpFolderPath = outputFolder </> "chess-tool-twic-tmp"
    logFunction ("Creating output directory: " <> outputFolder) "INFO"
    createDirectoryIfMissing True outputFolder
    logFunction ("Creating directory: " <> tmpFolderPath) "INFO"
    createDirectoryIfMissing True tmpFolderPath
--    TODO assert that iFrom < iTo
    if iFrom < iTo
      then do
        forM_ [iFrom..iTo] $ \i -> do
                  let fileExtension = ".zip"
                      fileName = "twic" ++ show i ++ "g"
                      filePath = tmpFolderPath </> (fileName ++ fileExtension)
                  logFunction ("Downloading: " <> fileName) "INFO"
                  Downloader.download ("https://theweekinchess.com/zips/" ++ fileName ++ fileExtension) filePath
                  logFunction ("Unzipping: " <> fileName) "INFO"
                  extractFiles filePath (tmpFolderPath </> fileName ++ ".pgn")
      else do
        logFunction ("\"index from\" = " ++ show iFrom ++ " is greater then \"index to\": " ++ show iTo ++ ", aborting the task execution" ) "ERROR"
    logFunction ("Joining pgns into single file") "INFO"
    let outputFileName = "twic" ++ show iFrom ++"-" ++ show iTo ++ ".pgn" 
    PGNFileConcatenator.processFolderWithPGNs  tmpFolderPath (outputFolder </> outputFileName ) 
    logFunction ("Joined successfully, file: " <> (outputFolder </> outputFileName)) "INFO"
    logFunction ("Removing tmp folder: " <> tmpFolderPath)  "INFO"
    removeDirectoryRecursive tmpFolderPath
    where extractFiles :: FilePath -> FilePath -> IO ()
          extractFiles zipPath outputFilePath  = do
            withArchive zipPath $ do
              names <- entryNames
              forM_ names $ \name -> do
                sourceEntry name (CC.sinkFile outputFilePath)
