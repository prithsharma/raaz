{-|

This module defines the hash instances for different hashes.

-}

{-# LANGUAGE TypeFamilies         #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Raaz.Hash.Sha1.Instance () where

import Control.Applicative ( (<$>) )
import Control.Monad       ( foldM )

import Raaz.Core.Memory
import Raaz.Core.Primitives
import Raaz.Core.Primitives.Hash
import Raaz.Core.Util.Ptr

import Raaz.Hash.Sha.Util
import Raaz.Hash.Sha1.Type
import Raaz.Hash.Sha1.Ref
import Raaz.Hash.Sha1.CPortable ()

----------------------------- SHA1 ---------------------------------------------

instance CryptoPrimitive SHA1 where
  type Recommended SHA1 = CGadget SHA1
  type Reference SHA1 = HGadget SHA1

instance Hash SHA1 where
  defaultCxt _ = SHA1 0x67452301
                      0xefcdab89
                      0x98badcfe
                      0x10325476
                      0xc3d2e1f0

  hashDigest = id

instance Gadget (HGadget SHA1) where
  type PrimitiveOf (HGadget SHA1)    = SHA1
  type MemoryOf (HGadget SHA1)       = CryptoCell SHA1
  newGadgetWithMemory                = return . HGadget
  getMemory (HGadget m)              = m
  apply (HGadget cc) n cptr          = do
    initial <- cellPeek cc
    final <- fst <$> foldM moveAndHash (initial,cptr) [1..n]
    cellPoke cc final
    where
      sz = blockSize (undefined :: SHA1)
      moveAndHash (cxt,ptr) _ = do newCxt <- sha1CompressSingle cxt ptr
                                   return (newCxt, ptr `movePtr` sz)

instance PaddableGadget (HGadget SHA1)
