module Account.Profile.View exposing (view)

import Account.Profile.Types as Types exposing (Model, Msg)
import Common.Types exposing (User)
import Common.Views exposing (empty, layout, loading)
import Header.View
import Html exposing (Html, dd, dl, dt, h1, section, text)
import Html.Attributes exposing (class)


view : Model -> Html Msg
view model =
    layout
        (List.map (Html.map Types.HeaderMsg) (Header.View.view model.header))
        (profile model)


profile : Model -> Html Msg
profile model =
    section
        [ class "profile" ]
        [ loadingOverlay model
        , h1
            []
            [ text "User Profile" ]
        , dl
            [ class "profile-list" ]
            (List.concat
                [ descriptionItem "Name" (fullName model.user)
                , descriptionItem "Email" model.user.email
                , descriptionItem "Bio" model.user.bio
                ]
            )
        ]


loadingOverlay : Model -> Html Msg
loadingOverlay model =
    case model.pageState of
        Types.Loading ->
            loading

        Types.Loaded ->
            empty


descriptionItem : String -> String -> List (Html msg)
descriptionItem term description =
    [ dt
        []
        [ text term ]
    , dd
        []
        [ text description ]
    ]


fullName : User -> String
fullName user =
    user.firstName ++ " " ++ user.lastName
