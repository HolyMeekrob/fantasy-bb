module Players.Create.Types exposing (..)

import Common.Types exposing (User)
import Common.Views.Forms exposing (Error)
import Date exposing (Date)
import Header.Types
import Http


type alias Model =
    { header : Header.Types.Model
    , pageState : PageState
    , player : Player
    , errors : List (Error FormField)
    }


type alias Player =
    { firstName : String
    , lastName : String
    , nickname : Maybe String
    , hometown : Maybe String
    , birthday : Maybe Date
    }


type alias CreatedPlayer =
    { id : Int
    }


type PageState
    = Loading
    | Loaded


type FormField
    = FirstName
    | LastName
    | Nickname
    | Hometown
    | Birthday
    | Summary


type Msg
    = HeaderMsg Header.Types.Msg
    | FetchUser
    | SetUser (Result Http.Error User)
    | SetFirstName String
    | SetLastName String
    | SetNickname String
    | SetHometown String
    | SetBirthday String
    | SubmitForm
    | PlayerCreated (Result Http.Error CreatedPlayer)
