module Header.View exposing (headerView, view)

import Common.Types exposing (User)
import Common.Views exposing (empty)
import Header.Types as Types exposing (Model, Msg, Notification)
import Html exposing (Html, a, button, div, img, li, nav, span, text, ul)
import Html.Attributes exposing (alt, attribute, class, classList, href, src)
import Html.Events exposing (onClick)
import String


headerView : (Msg -> msg) -> Model -> List (Html msg)
headerView createMsg model =
    (List.map (Html.map createMsg) (view model))


view : Model -> List (Html Msg)
view model =
    [ div
        [ class "header-top" ]
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
            (userArea model.user)
        ]
    , Maybe.map navigation model.user
        |> Maybe.withDefault empty
    , notifications model.notifications
    ]


navigation : User -> Html Msg
navigation user =
    nav
        []
        [ div
            [ class "top-nav" ]
            [ div
                [ classList
                    [ ( "nav-item", True )
                    , ( "has-sub", True )
                    , ( "not-displayed", not user.isAdmin )
                    ]
                ]
                [ text "Admin"
                , div
                    [ class "sub-nav" ]
                    [ navLink
                        "/admin/season/create"
                        "Create season"
                    ]
                ]
            ]
        ]


navLink : String -> String -> Html Msg
navLink link linkText =
    div
        [ class "nav-item" ]
        [ a
            [ href link ]
            [ text linkText ]
        ]


userArea : Maybe User -> List (Html Msg)
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


notifications : List Notification -> Html Msg
notifications messages =
    div
        [ class "notification-area" ]
        [ ul
            [ class "notification-list" ]
            (List.map notification messages)
        ]


notification : Notification -> Html Msg
notification message =
    li
        [ class "notification" ]
        [ text message.message ]
