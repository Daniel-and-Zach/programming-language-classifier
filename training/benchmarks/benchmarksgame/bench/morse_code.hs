 import System.IOimport MorseCodeimport MorsePlaySox -- Read standard input, converting text to Morse code, then playing the result.-- We turn off buffering on stdin so it will play as you type.main = do  hSetBuffering stdin NoBuffering  text <- getContents  play $ toMorse text ,  module MorseCode (Morse, MSym(..), toMorse) where import Data.Listimport Data.Maybeimport qualified Data.Map as M type Morse = [MSym]data MSym = Dot | Dash | SGap | CGap | WGap deriving (Show) -- Based on the table of International Morse Code letters and numerals at -- http://en.wikipedia.org/wiki/Morse_code.dict = M.fromList       [('a', m ".-"   ), ('b', m "-..." ), ('c', m "-.-." ), ('d', m "-.."  ),        ('e', m "."    ), ('f', m "..-." ), ('g', m "--."  ), ('h', m "...." ),        ('i', m ".."   ), ('j', m ".---" ), ('k', m "-.-"  ), ('l', m ".-.." ),        ('m', m "--"   ), ('n', m "-."   ), ('o', m "---"  ), ('p', m ".--." ),        ('q', m "--.-" ), ('r', m ".-."  ), ('s', m "..."  ), ('t', m "-"    ),        ('u', m "..-"  ), ('v', m "...-" ), ('w', m ".--"  ), ('x', m "-..-" ),        ('y', m "-.--" ), ('z', m "--.." ), ('1', m ".----"), ('2', m "..---"),         ('3', m "...--"), ('4', m "....-"), ('5', m "....."), ('6', m "-...."),         ('7', m "--..."), ('8', m "---.."), ('9', m "----."), ('0', m "-----")]    where m = intersperse SGap . map toSym          toSym '.' = Dot          toSym '-' = Dash -- Convert a string to a stream of Morse symbols.  We enhance the usual dots-- and dashes with special "gap" symbols, which indicate the border between-- symbols, characters and words.  This allows a player to easily adjust its-- timing by simply looking at the current symbol, rather than trying to keep-- track of state.toMorse :: String -> MorsetoMorse = fromWords . words . weed    where fromWords = intercalate [WGap] . map fromWord          fromWord  = intercalate [CGap] . map fromChar          fromChar  = fromJust . flip M.lookup dict          weed      = filter (\c -> c == ' ' || M.member c dict) ,  module MorsePlaySox (play) where import Sound.Sox.Playimport Sound.Sox.Option.Formatimport Sound.Sox.Signal.Listimport Data.Intimport System.Exitimport MorseCode samps = 15           -- samples/cyclefreq  = 700          -- cycles/second (frequency)rate  = samps * freq -- samples/second (sampling rate) type Samples = [Int16] -- One cycle of silence and a sine wave.mute, sine :: Samplesmute = replicate samps 0sine = let n = fromIntegral samps           f k = 8000.0 * sin (2*pi*k/n)       in map (round . f . fromIntegral) [0..samps-1] -- Repeat samples until we have the specified duration in seconds.rep :: Float -> Samples -> Samplesrep dur = take n . cycle    where n = round (dur * fromIntegral rate) -- Convert Morse symbols to samples.  Durations are in seconds, based on -- http://en.wikipedia.org/wiki/Morse_code#Representation.2C_timing_and_speeds.toSamples :: MSym -> SamplestoSamples Dot  = rep 0.1 sinetoSamples Dash = rep 0.3 sinetoSamples SGap = rep 0.1 mutetoSamples CGap = rep 0.3 mutetoSamples WGap = rep 0.7 mute -- Interpret the stream of Morse symbols as sound.play :: Morse -> IO ExitCodeplay = simple put none rate . concatMap toSamples 