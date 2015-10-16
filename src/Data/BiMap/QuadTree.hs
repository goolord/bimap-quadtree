{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE PatternGuards   #-}
---------------------------------------------------
--  ____  _ __  __                ___                  _ _____              
-- | __ )(_)  \/  | __ _ _ __    / _ \ _   _  __ _  __| |_   _| __ ___  ___ 
-- |  _ \| | |\/| |/ _` | '_ \  | | | | | | |/ _` |/ _` | | || '__/ _ \/ _ \
-- | |_) | | |  | | (_| | |_) | | |_| | |_| | (_| | (_| | | || | |  __/  __/
-- |____/|_|_|  |_|\__,_| .__/   \__\_\\__,_|\__,_|\__,_| |_||_|  \___|\___|
--                      |_|                                                 
--
-- Module:  Data.BiMap
-- Author:  sternenseemann
-- Licence: LGPL-3
--
-- A BiMap is isomorphic to a list of isomorphisms.
---------------------------------------------------

module Data.BiMap.QuadTree
  ( empty
  , fromList
  , insert
  , lookup
  , (!)
    ) where


import           Prelude    hiding (lookup)

import           Data.Maybe (Maybe (..))

infixl 9 !

-- | A bidirectional Map.
data BiMap k y = Branch
  { key        :: k
  , yek        :: y
  , smallSmall :: BiMap k y
  , smallGreat :: BiMap k y
  , greatSmall :: BiMap k y
  , greatGreat :: BiMap k y
  }
  | Leaf
  deriving (Show, Eq)

-- | The empty BiMap
empty :: BiMap k y
empty = Leaf

-- | A BiMap containing only the relation between one element of type k and one element of type y
singleton :: (Ord k, Ord y) => k -> y -> BiMap k y
singleton key yek = insert key yek empty

insert :: (Ord k, Ord y) => k -> y -> BiMap k y -> BiMap k y
insert key yek Leaf = Branch key yek Leaf Leaf Leaf Leaf
insert key yek (Branch key' yek' ss sg gs gg)
  | key < key' && yek < yek' = Branch key' yek' (insert key yek ss) sg gs gg
  | key < key' && yek > yek' = Branch key' yek' ss (insert key yek sg) gs gg
  | key > key' && yek < yek' = Branch key' yek' ss sg (insert key yek gs) gg
  | key > key' && yek > yek' = Branch key' yek' ss sg gs (insert key yek gg)
  | otherwise                = error "key and yek must be unique"

fromList :: (Ord k, Ord y) => [(k, y)] -> BiMap k y
fromList = foldl (flip . uncurry $ insert) empty

(!) :: (Ord k, Ord y) => Either k y -> BiMap k y -> Maybe (k, y)
query ! bimap = lookup query bimap

lookup :: (Ord k, Ord y) => Either k y -> BiMap k y -> Maybe (k, y)
lookup _ Leaf = Nothing
lookup query@(Left key) (Branch key' yek' ss sg gs gg)
  | key == key' = Just (key', yek')
  | key <  key' = doubleLookup query ss sg
  | key >  key' = doubleLookup query gg gs
lookup query@(Right yek) (Branch key' yek' ss sg gs gg)
  | yek == yek' = Just (key', yek')
  | yek <  yek' = doubleLookup query ss gs
  | yek >  yek' = doubleLookup query gg sg

doubleLookup :: (Ord k, Ord y) => Either k y -> BiMap k y -> BiMap k y -> Maybe (k, y)
doubleLookup query a b = pickJust (lookup query a) (lookup query b)

pickJust :: Maybe a -> Maybe a -> Maybe a
pickJust Nothing Nothing   = Nothing
pickJust (Just _) (Just _) = Nothing
pickJust (Just x) Nothing  = Just x
pickJust Nothing (Just y)  = Just y

humanization :: BiMap String Int
humanization = fromList [ ("two", 2)
                        , ("three", 3)
                        , ("nine", 9)
                        , ("ten", 10)
                        , ("four", 4)
                        , ("five", 5)
                        , ("eight", 8)
                        , ("seven", 7)
                        , ("six", 6)
                        , ("eleven", 11)
                        , ("twelve", 12)
                        , ("one", 1)
                        , ("zero", 0) ]
