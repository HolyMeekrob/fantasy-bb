module Account.Profile.State exposing (init, subscriptions, update)

import Account.Profile.Rest as Rest exposing (saveProfile)
import Account.Profile.Types as Types exposing (Model, Msg)
import Header.State
import Common.Commands exposing (send)
import Common.Rest exposing (fetchUser)


initialModel : Model
initialModel =
    { user =
        { firstName = "Unknown"
        , lastName = "Unkown"
        , email = "Unknown"
        , bio = "Unknown"
        , avatarUrl = ""
        }
    , header = Header.State.initialModel
    , pageState = Types.Loading
    , input =
        { bio = "Unknown"
        }
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, send Types.FetchUser )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Types.HeaderMsg headerMsg ->
            let
                ( headerModel, headerCmd ) =
                    Header.State.update headerMsg model.header
            in
                ( { model | header = headerModel }
                , Cmd.map Types.HeaderMsg headerCmd
                )

        Types.FetchUser ->
            { model | pageState = Types.Loading } ! [ fetchUser Types.SetUser ]

        Types.SetUser (Err _) ->
            initialModel ! []

        Types.SetUser (Ok newUser) ->
            ( { model
                | user = newUser
                , header = Just newUser
                , pageState = Types.View
                , input =
                    { bio = newUser.bio
                    }
              }
            , Cmd.none
            )

        Types.EditProfile ->
            { model | pageState = Types.Edit } ! []

        Types.CancelEdit ->
            let
                existingInput =
                    model.input

                newInput =
                    { existingInput | bio = model.user.bio }
            in
                { model | input = newInput, pageState = Types.View } ! []

        Types.SaveEdit ->
            let
                existingUser =
                    model.user

                newUser =
                    { existingUser | bio = model.input.bio }
            in
                { model | user = newUser, pageState = Types.Loading }
                    ! [ saveProfile model.input.bio ]

        Types.ViewProfile (Ok _) ->
            { model | pageState = Types.View } ! []

        Types.ViewProfile (Err _) ->
            { model | pageState = Types.View } ! []

        Types.BioChanged newBio ->
            let
                existingInput =
                    model.input

                newInput =
                    { existingInput | bio = newBio }
            in
                { model | input = newInput } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
