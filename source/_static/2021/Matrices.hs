import Data.Matrix

mat3, mat5, mat6, mat7, mat8, mat9, mat10, mat11 :: Matrix Float

mat3 = fromLists [ [1,2,3], [4,5,6], [7,8,10] ]
mat4 = fromLists [ [1,2,3, 0], [-6, 4,5,6], [7,8,10, 10], [-3, -2, -1, 4] ]
mat5 = fromLists [[1, 2, 3, 4 , 5],
        [8, 7, 8, 9, 10],
        [11, 13, 14, 12, 15],
        [24, 26, 56, 23, 12],
        [32, 45, 23, 76, 1]]

mat6 = fromLists [[1, 2, 3, 4 , 5, 11],
        [8, 7, 8, 9, 10, 18],
        [11, 13, 14, 12, 15, 34],
        [24, 26, 56, 23, 12, 32],
        [32, 45, 23, 76, 1, 23],
        [66, 23, 35, 56, 21, 15]]

mat7 = fromLists [[1, 2, 3, 4 , 5, 11, 66],
        [8, 7, 8, 9, 10, 18, 55],
        [11, 13, 14, 12, 15, 34, 8],
        [24, 26, 56, 23, 12, 32, 6],
        [32, 45, 23, 76, 1, 23, 5],
        [66, 23, 35, 56, 21, 15, 10],
        [12, 4, 34, 43, 89, 91, 11]]

mat8 = fromLists [[1, 2, 3, 4 , 5, 11, 66, 78],
        [8, 7, 8, 9, 10, 18, 55, 22],
        [11, 13, 14, 12, 15, 34, 8, 33],
        [24, 26, 56, 23, 12, 32, 6, 45],
        [32, 45, 23, 76, 1, 23, 5, 34],
        [66, 23, 35, 56, 21, 15, 10, 65],
        [12, 4, 34, 43, 89, 91, 11, 13],
        [121, 34, 37, 43, 49, 92, 10, 113]]


mat9 = fromLists [[1, 2, 3, 4 , 5, 11, 66, 78, 9],
        [8, 7, 8, 9, 10, 18, 55, 22, 2],
        [11, 13, 14, 12, 15, 34, 8, 33, 4],
        [24, 26, 56, 23, 12, 32, 6, 45, 1],
        [32, 45, 23, 76, 1, 23, 5, 34, 67],
        [66, 23, 35, 56, 21, 15, 10, 65, 87],
        [12, 4, 34, 43, 89, 91, 11, 13, 34],
        [121, 34, 37, 43, 49, 92, 10, 113, 55],
        [322, 145, 21, 74, 2, 3, 15, 35, 47]]

mat10 = fromLists [[1, 2, 3, 4 , 5, 11, 66, 78, 9, 2],
        [8, 7, 8, 9, 10, 18, 55, 22, 2, 3],
        [11, 13, 14, 12, 15, 34, 8, 33, 4, 17],
        [24, 26, 56, 23, 12, 32, 6, 45, 1, 22],
        [32, 45, 23, 76, 1, 23, 5, 34, 67, 10],
        [66, 23, 35, 56, 21, 15, 10, 65, 87, 1],
        [12, 4, 34, 43, 89, 91, 11, 13, 34, 43],
        [121, 34, 37, 43, 49, 92, 10, 113, 55, 77],
        [322, 145, 21, 74, 2, 3, 15, 35, 47, 17],
        [10, 11, 12, 9, 115, 334, 28, 31, 14, 52]]

mat11 = fromLists [[1, 2, 3, 4 , 5, 11, 66, 78, 9, 2, 11],
        [8, 7, 8, 9, 10, 18, 55, 22, 2, 3, 12],
        [11, 13, 14, 12, 15, 34, 8, 33, 4, 17, 11],
        [24, 26, 56, 23, 12, 32, 6, 45, 1, 22, 13],
        [32, 45, 23, 76, 1, 23, 5, 34, 67, 10, 14],
        [66, 23, 35, 56, 21, 15, 10, 65, 87, 1, 15],
        [12, 4, 34, 43, 89, 91, 11, 13, 34, 43, 16],
        [121, 34, 37, 43, 49, 92, 10, 113, 55, 77, 10],
        [322, 145, 21, 74, 2, 3, 15, 35, 47, 17, 9],
        [10, 11, 12, 9, 115, 334, 28, 31, 14, 52, 18],
        [122, 34, 27, 43, 39, 82, 11, 114, 55, 77, 9]]


-- TODO: try detLaplace and detLU


-- module Matrix where

-- import Data.List

-- type Vector = [Float]
-- type Matrix = [Vector]

-- --basic constructions for vectors

-- zeroVector :: Int -> Vector
-- zeroVector n = replicate n 0

-- --basic operations for vectors

-- dotProduct :: Vector -> Vector -> Float
-- dotProduct v w = sum ( zipWith (*) v w )

-- vectorSum :: Vector -> Vector -> Vector
-- vectorSum = zipWith (+)

-- vectorScalarProduct :: Float -> Vector -> Vector
-- vectorScalarProduct n vec = [ n * x | x <- vec ]

-- --basic constructions for matrices

-- elemMatrix :: Int -> Int -> Int -> Float -> Matrix
-- -- elemMatrix n i j v   is the n-by-n elementary matrix with 
-- -- entry  v  in the (i,j) place
-- elemMatrix n i j v
--   = [ [ entry row column | column <- [1..n] ] | row <- [1..n] ]
--   where
--   entry x y
--     | x == y           = 1
--     | x == i && y == j = v
--     | otherwise        = 0

-- idMatrix :: Int -> Matrix
-- idMatrix n = elemMatrix n 1 1 1

-- zeroMatrix :: Int -> Int -> Matrix
-- zeroMatrix i j = replicate i (zeroVector j)

-- --basic operations for matrices

-- matrixSum :: Matrix -> Matrix -> Matrix
-- matrixSum = zipWith vectorSum

-- matrixScalarProduct :: Float -> Matrix -> Matrix
-- matrixScalarProduct n m = [ vectorScalarProduct n row | row <- m ]

-- matrixProduct :: Matrix -> Matrix -> Matrix
-- matrixProduct m n = [ map (dotProduct r) (transpose n) | r <- m ]

-- {- The determinant and inverse functions given here are only for examples
-- of Haskell syntax.  Efficient versions using row operations are implemented
-- in RowOperations.hs .

-- --determinant using cofactors
-- -}

-- remove :: Matrix -> Int -> Int -> Matrix
-- remove m i j  
--   | m == [] || i < 1 || i > numRows m || j < 1 || j > numColumns m
--     = error "(i,j) out of range"
--   | otherwise = transpose ( cut (transpose ( cut m i ) ) j )

-- determinant :: Matrix -> Float
-- determinant [] = error "determinant: 0-by-0 matrix"
-- determinant [[n]] = n
-- determinant m = sum [ (-1)^(j+1) * (head m)!!(j-1) * determinant (remove m 1 j) | 
--   j <- [1..(numColumns m) ] ]

-- --inverse

-- cofactor :: Matrix -> Int -> Int -> Float
-- cofactor m i j = (-1)^(i+j) * determinant (remove m i j)

-- cofactorMatrix :: Matrix -> Matrix
-- cofactorMatrix m = [ [ (cofactor m i j) | j <- [1..n] ] | i <- [1..n] ]
--   where
--   n = length m

-- -- matrix utilities

-- numRows :: Matrix -> Int
-- numRows = length

-- numColumns :: Matrix -> Int
-- numColumns = length . head

-- ----------------------------------------------------------
-- -- other utilities

-- cut :: [a] -> Int -> [a]
-- cut [] n = []
-- cut xs n
--   | n < 1 || n > (length xs) = xs
--   | otherwise = (take (n-1) xs) ++ drop n xs

-- showMatrix :: Matrix -> IO()
-- showMatrix m = putStr (rowsWithEndlines m)
--   where
--   rowsWithEndlines m = concat ( map (\x -> (show x) ++ "\n") m )

-- ----------------------------------------------------------
-- -- test data



---------------------------------------------------------
-- Gauss Algorithm

-- determinant_gauss :: Matrix -> Float
-- determinant_gauss m =
--    let trk = triangular m
--     in ()product . (map head)


-- triangular :: Matrix -> (Matrix, Float)
-- triangular [] = []
-- triangular m  = row:(triangular rows')
--     where
--     (row:rows) = rotatePivot m    -- see discussion below
--     rows' = map f rows
--     f bs
--         | (head bs) == 0 = (drop 1 bs, 0)
--         | otherwise      = (drop 1 $ zipWith (-) (map (*c) bs) row
--         where 
--         c = (head row) / (head bs)    -- suitable multiple

-- rotatePivot :: Matrix -> Matrix
-- rotatePivot (row:rows)
--     | (head row) /= 0 = (row:rows)
--     | otherwise       = rotatePivot (rows ++ [row])

----------------------------------------------------------
