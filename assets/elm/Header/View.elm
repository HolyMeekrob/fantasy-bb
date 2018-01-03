module Header.View exposing (view)

import Common.Types exposing (User)
import Header.Types as Types exposing (Model, Msg)
import Html exposing (Html, a, button, div, img, text)
import Html.Attributes exposing (alt, attribute, class, href, src)
import Html.Events exposing (onClick)
import String


view : Model -> List (Html Msg)
view model =
    [ div
        [ attribute "role" "banner"
        , class "banner"
        ]
        [ a
            [ href "/" ]
            [ img
                [ src "/images/banner.png"
                , alt "Site banner"
                , class "banner-image"
                ]
                []
            ]
        ]
    , div
        [ class "user-area" ]
        (userArea model)
    ]


userArea : Model -> List (Html Msg)
userArea model =
    case model of
        Nothing ->
            loggedOut

        Just user ->
            loggedIn user


loggedOut : List (Html Msg)
loggedOut =
    [ a
        [ href "/login" ]
        [ text "Log in" ]
    ]


loggedIn : User -> List (Html Msg)
loggedIn user =
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
        firstName =
            if user.firstName == "" then
                ""
            else
                ", " ++ user.firstName
    in
        String.join "" [ "Welcome", firstName, "!" ]
