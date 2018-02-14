module Season.Create.Types exposing (..)

import Common.Types exposing (User)
import Header.Types
import Date exposing (Date)
import Http


type alias Model =
    { header : Header.Types.Model
    , name : String
    , start : Maybe Date
    , errors : List Error
    }


type FormField
    = Name
    | Start


type alias Error =
    ( FormField, String )


type Msg
    = HeaderMsg Header.Types.Msg
    | FetchUser
    | SetUser (Result Http.Error User)
    | SetName String
    | SetStart String
    | SubmitForm
