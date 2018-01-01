module Header.Rest exposing (logOut)

import Header.Types as Types exposing (Msg)
import Http


logOut : Cmd Msg
logOut =
    let
        url =
            "http://localhost:4000/auth/logout"
    in
        Http.request
            { method = "DELETE"
            , headers = []
            , url = url
            , body = Http.emptyBody
            , expect = Http.expectString
            , timeout = Maybe.Nothing
            , withCredentials = False
            }
            |> Http.send Types.LogOut
