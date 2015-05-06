
import Debug.Trace

ggt :: Int -> Int -> Int
ggt 0 0 =  error "Prelude.ggt: ggt 0 0 is undefined"
ggt x y =  trace (show (x,y)) $ ggt' (abs x) (abs y) where
  ggt' a 0  =  a
  ggt' a b  =  ggt' b (a `rem` b)

main = putStrLn $ show $ foldl1 ggt [45,45,65,35,765,35,875,25,325]