module Account.Profile.View exposing (view)

import Account.Profile.Types exposing (Model, Msg)
import Common exposing (User)
import Html exposing (Html, div, text)


view : Model -> Html Msg
view model =
    div
        []
        [ div
            []
            [ text <| fullName model.user ]
        , div
            []
            [ text model.user.email ]
        , div
            []
            [ text model.user.bio ]
        ]


fullName : User -> String
fullName user =
    user.firstName ++ " " ++ user.lastName
