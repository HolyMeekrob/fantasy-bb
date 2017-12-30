module Header.View exposing (view)

import Header.Types as Types exposing (Model, Msg)
import Html exposing (Html, button, div, h5, img, text)
import Html.Attributes exposing (src)
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
            , logout model
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


logout : Model -> Html Msg
logout model =
    if model.isLoggedIn then
        button
            [ onClick Types.RequestLogOut ]
            [ text "Log out" ]
    else
        text ""
