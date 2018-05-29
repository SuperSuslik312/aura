{-# LANGUAGE OverloadedStrings #-}

{-

Copyright 2012 - 2018 Colin Woodbury <colin@fosskers.ca>

This file is part of Aura.

Aura is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Aura is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Aura.  If not, see <http://www.gnu.org/licenses/>.

-}

module Aura.Pkgbuild.Base where

import           Aura.Core
import           Aura.Monad.Aura
import           Aura.Pkgbuild.Editing
import           Aura.Settings.Base
import           BasePrelude hiding (FilePath)
import qualified Data.Text as T
import           Shelly

---

pkgbuildCache :: FilePath
pkgbuildCache = "/var/cache/aura/pkgbuilds/"

pkgbuildPath :: T.Text -> FilePath
pkgbuildPath p = pkgbuildCache </> p <.> "pb"

-- One of my favourite functions in this code base.
pbCustomization :: Settings -> Buildable -> Sh Buildable
pbCustomization ss = foldl (>=>) pure [customizepkg ss, hotEdit ss]

-- | Package a Buildable, running the customization handler first.
packageBuildable :: Buildable -> Aura Package
packageBuildable b = do
  ss <- ask
  b' <- shelly $ pbCustomization ss b
  pure Package
    { pkgNameOf        = baseNameOf b'
    , pkgVersionOf     = bldVersionOf b'
    , pkgDepsOf        = bldDepsOf b'
    , pkgInstallTypeOf = Build b' }
