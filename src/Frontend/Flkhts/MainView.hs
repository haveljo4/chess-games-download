{-# LANGUAGE OverloadedStrings #-}
module Frontend.Flkhts.MainView (main,replMain) where
import qualified Graphics.UI.FLTK.LowLevel.FL as FL
import Graphics.UI.FLTK.LowLevel.Fl_Types
import Graphics.UI.FLTK.LowLevel.FLTKHS
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import qualified Backend.TWICDownloadManager as TWICDownloadManager
import qualified Backend.ChessComDownloadManager as ChessComDownloadManager
import qualified Frontend.Flkhts.TWICWindow as TWICWin
import qualified Frontend.Flkhts.ChessComWindow as ChessComWin
import qualified Frontend.Flkhts.CommonHelper as Helper
import System.FilePath ((</>))

-- | Start the UI.
uiStart :: IO ()
uiStart = do
  -- Create the main window
  window <- windowNew
             (Size (Width 600) (Height 400))
             Nothing
             (Just "Chess downloader")

  -- Create the Chess.com button
  buttonChessCom <- buttonNew
                (Rectangle (Position (X 10) (Y 30)) (Size (Width 290) (Height 30)))
                (Just "Chess.com")
  -- Set the callback for the Chess.com button
  setCallback buttonChessCom (\_ -> do ChessComWin.uiChessComDownload)

  -- Create the TWIC button
  buttonTwic <- buttonNew
                (Rectangle (Position (X 300) (Y 30)) (Size (Width 290) (Height 30)))
                (Just "TWIC")
  -- Set the callback for the TWIC button
  setCallback buttonTwic (\_ -> do TWICWin.uiTwicDownload)

  -- Create the Join pgns button, TODO not implemented yet
--  buttonJoinPGNs <- buttonNew
--                (Rectangle (Position (X 370) (Y 30)) (Size (Width 180) (Height 30)))
--                (Just "Join pgns")
  text <- boxNew
            (Rectangle (Position (X 190) (Y 360)) (Size (Width 180) (Height 30)))
            (Just "Copyright Josef Havelka (c) 2023")
  
  imageBox <- boxNew
              (Rectangle (Position (X 190) (Y 200)) (Size (Width 180) (Height 30)))
              (Nothing)
            
  frontImage <- pngImageNew  "icon.png"

  case frontImage of
    (Right image) -> setImage imageBox (Just image)
    Left _ -> putStrLn "Couldn't read the image"
  Helper.setIconToWindow window
  -- Add the widgets to the window
  end window
  showWidget window

-- | The main entry point.
main :: IO ()
main = uiStart >> FL.run >> FL.flush

-- | The REPL entry point.
replMain :: IO ()
replMain = uiStart >> FL.replRun