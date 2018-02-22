module Header.Types exposing (..)

import Common.Types exposing (User)
import Http
import Time exposing (Time)


type alias Model =
    { user : Maybe User
    , notifications : List Notification
    }


type alias Notification =
    { message : String
    , timer : Int
    }


type Msg
    = RequestLogOut
    | LogOut (Result Http.Error String)
    | AddNotification String
    | UpdateNotifications Time
