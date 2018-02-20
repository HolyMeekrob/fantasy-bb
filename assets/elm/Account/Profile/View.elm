module Account.Profile.View exposing (view)

import Account.Profile.Types as Types exposing (Model, Msg)
import Common.Types exposing (User)
import Common.Views exposing (empty, layout, loading)
import Editable
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
    if (Editable.isEditable model.user) then
        editProfile model
    else
        viewProfile model


viewProfile : Model -> Html Msg
viewProfile model =
    let
        user =
            getUser model
    in
        section
            [ class "profile" ]
            [ loadingOverlay model
            , h1
                [ class "page-title"
                , onClick Types.EditProfile
                ]
                [ text "User Profile "
                , iconWithOptions
                    edit
                    FA.Solid
                    [ FA.Size FA.ExtraSmall ]
                    [ class "clickable" ]
                ]
            , dl
                [ class "profile-list" ]
                (List.concat
                    [ descriptionItem "Name" (fullName user)
                    , descriptionItem "Email" user.email
                    , descriptionItem "Bio" (getBio user)
                    ]
                )
            ]


getUser : Model -> User
getUser model =
    Editable.value model.user


getBio : User -> String
getBio user =
    if (String.isEmpty user.bio) then
        "No bio"
    else
        user.bio


editProfile : Model -> Html Msg
editProfile model =
    let
        user =
            getUser model
    in
        section
            [ class "profile" ]
            [ loadingOverlay model
            , h1
                []
                [ text "User Profile " ]
            , dl
                [ class "profile-list" ]
                (List.concat
                    [ descriptionItem "Name" (fullName user)
                    , descriptionItem "Email" user.email
                    , editItem "Bio" user.bio Types.UpdateBio
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
