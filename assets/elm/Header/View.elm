module Header.View exposing (view)

import Header.Types as Types exposing (Model, Msg)
import Html exposing (Html, a, button, div, h5, img, text)
import Html.Attributes exposing (href, src)
import Html.Events exposing (onClick)
import String


view : Model -> Html Msg
view model =
    div
        []
        [ h5
            []
            [ text (greeting model)
            , img
                [ src model.user.avatarUrl ]
                []
            , loginLogout model
            ]
        ]


greeting : Model -> String
greeting model =
    let
        lastName =
            if model.user.lastName == "" then
                ""
            else
                " " ++ model.user.lastName

        firstName =
            if model.user.firstName == "" then
                ""
            else
                ", " ++ model.user.firstName
    in
        String.join "" [ "Welcome", firstName, lastName, "!" ]


loginLogout : Model -> Html Msg
loginLogout model =
    if model.isLoggedIn then
        button
            [ onClick Types.RequestLogOut ]
            [ text "Log out" ]
    else
        a
            [ href "/login" ]
            [ text "Log in" ]
