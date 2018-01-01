module Header.View exposing (view)

import Common exposing (User)
import Header.Types as Types exposing (Model, Msg)
import Html exposing (Html, a, button, div, img, text)
import Html.Attributes exposing (class, href, src)
import Html.Events exposing (onClick)
import String


view : Model -> Html Msg
view model =
    case model of
        Nothing ->
            loggedOut

        Just user ->
            loggedIn user


loggedOut : Html Msg
loggedOut =
    a
        [ href "/login" ]
        [ text "Log in" ]


loggedIn : User -> Html Msg
loggedIn user =
    div
        []
        [ a
            [ href "/account/profile" ]
            [ img
                [ src user.avatarUrl
                , class "avatar"
                ]
                []
            ]
        , div
            [ class "greeting" ]
            [ text (greeting user) ]
        , button
            [ onClick Types.RequestLogOut ]
            [ text "Log out" ]
        ]


greeting : User -> String
greeting user =
    let
        lastName =
            if user.lastName == "" then
                ""
            else
                " " ++ user.lastName

        firstName =
            if user.firstName == "" then
                ""
            else
                ", " ++ user.firstName
    in
        String.join "" [ "Welcome", firstName, lastName, "!" ]
