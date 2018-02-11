module Account.Profile.View exposing (view)

import Account.Profile.Types as Types exposing (Model, Msg)
import Common.Types exposing (User)
import Common.Views exposing (empty, layout, loading)
import FontAwesome as FA exposing (edit, iconWithOptions)
import Header.View exposing (headerView)
import Html exposing (Html, a, button, dd, dl, dt, h1, section, text, textarea)
import Html.Attributes exposing (class, href, value)
import Html.Events exposing (onClick, onInput)


view : Model -> Html Msg
view model =
    layout
        (headerView Types.HeaderMsg model.header)
        (profile model)


profile : Model -> Html Msg
profile model =
    case model.pageState of
        Types.Edit ->
            editProfile model

        _ ->
            viewProfile model


viewProfile : Model -> Html Msg
viewProfile model =
    section
        [ class "profile" ]
        [ loadingOverlay model
        , h1
            [ onClick Types.EditProfile ]
            [ text "User Profile "
            , iconWithOptions
                edit
                FA.Solid
                [ FA.Size FA.ExtraSmall ]
                [ class "clickable"
                ]
            ]
        , dl
            [ class "profile-list" ]
            (List.concat
                [ descriptionItem "Name" (fullName model.user)
                , descriptionItem "Email" model.user.email
                , descriptionItem "Bio" (getBio model)
                ]
            )
        ]


getBio : Model -> String
getBio model =
    if (String.isEmpty model.user.bio) then
        "No bio"
    else
        model.user.bio


editProfile : Model -> Html Msg
editProfile model =
    section
        [ class "profile" ]
        [ loadingOverlay model
        , h1
            []
            [ text "User Profile " ]
        , dl
            [ class "profile-list" ]
            (List.concat
                [ descriptionItem "Name" (fullName model.user)
                , descriptionItem "Email" model.user.email
                , editItem "Bio" model.input.bio Types.BioChanged
                ]
            )
        , button
            [ onClick Types.CancelEdit ]
            [ text "Cancel" ]
        , button
            [ onClick Types.SaveEdit ]
            [ text "Save " ]
        ]


loadingOverlay : Model -> Html Msg
loadingOverlay model =
    case model.pageState of
        Types.Loading ->
            loading

        _ ->
            empty


descriptionItem : String -> String -> List (Html Msg)
descriptionItem term description =
    [ dt
        []
        [ text term ]
    , dd
        []
        [ text description ]
    ]


editItem : String -> String -> (String -> Msg) -> List (Html Msg)
editItem term description onInputFunc =
    [ dt
        []
        [ text term ]
    , dd
        []
        [ textarea
            [ value description
            , onInput onInputFunc
            ]
            []
        ]
    ]


fullName : User -> String
fullName user =
    user.firstName ++ " " ++ user.lastName
