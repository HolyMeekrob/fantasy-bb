module Season.Create.Types exposing (..)

import Header.Types


type alias Model =
    { header : Header.Types.Model
    , name : String
    }


type Msg
    = HeaderMsg Header.Types.Msg
