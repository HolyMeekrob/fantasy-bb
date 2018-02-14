module Season.Create.Types exposing (..)

import Common.Types exposing (User)
import Header.Types
import Http


type alias Model =
    { header : Header.Types.Model
    , name : String
    , errors : List Error
    }


type FormField
    = Name


type alias Error =
    ( FormField, String )


type Msg
    = HeaderMsg Header.Types.Msg
    | FetchUser
    | SetUser (Result Http.Error User)
    | SetName String
    | SubmitForm
