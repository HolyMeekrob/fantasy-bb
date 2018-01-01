module Account.Profile.View exposing (view)

import Account.Profile.Types as Types exposing (Model, Msg)
import Common exposing (User)
import Header.View
import Html exposing (Html, div, header, main_, text)
import Html.Attributes exposing (class)


view : Model -> Html Msg
view model =
    div
        [ class "wrapper" ]
        [ header
            [ class "header" ]
            [ Html.map Types.HeaderMsg <| Header.View.view model.header ]
        , main_
            [ class "content" ]
            [ profile model ]
        ]


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
