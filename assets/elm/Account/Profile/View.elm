module Account.Profile.View exposing (view)

import Account.Profile.Types as Types exposing (Model, Msg)
import Common.Types exposing (User)
import Common.Views exposing (layout)
import Header.View
import Html exposing (Html, div, text)


view : Model -> Html Msg
view model =
    layout
        (Html.map Types.HeaderMsg <| Header.View.view model.header)
        (profile model)


profile : Model -> Html Msg
profile model =
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
