port module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onInput, onSubmit)


port incomingMessage : (String -> msg) -> Sub msg


port outgoingMessage : String -> Cmd msg


type alias Flags =
    ()


main : Program Flags Model Message
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type ChatType
    = Outgoing
    | Incoming


type alias ChatMessage =
    { content : String
    , chatType : ChatType
    }


type alias Model =
    { messages : List ChatMessage
    , draft : String
    }


init : Flags -> ( Model, Cmd Message )
init _ =
    ( Model [] "", Cmd.none )


type Message
    = GotMessage String
    | SendMessage
    | DraftChanged String


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        SendMessage ->
            let
                messages =
                    List.append model.messages [ ChatMessage model.draft Outgoing ]
            in
            ( Model messages "", outgoingMessage model.draft )

        GotMessage message ->
            let
                messages =
                    List.append model.messages [ ChatMessage message Incoming ]
            in
            ( { model | messages = messages }, Cmd.none )

        DraftChanged value ->
            ( { model | draft = value }, Cmd.none )


subscriptions : Model -> Sub Message
subscriptions _ =
    incomingMessage GotMessage


view : Model -> Html Message
view model =
    Html.main_ []
        [ Html.form [ onSubmit SendMessage ]
            [ Html.fieldset []
                [ Html.legend [] [ Html.text "Socket chat" ]
                , Html.label []
                    [ Html.text "Message content: "
                    , Html.input
                        [ type_ "text"
                        , onInput DraftChanged
                        , value model.draft
                        ]
                        []
                    ]
                ]
            ]
        , Html.ul [] (List.map chatMessageToListItem model.messages)
        ]


chatMessageToListItem : ChatMessage -> Html Message
chatMessageToListItem message =
    Html.li [] [ formatChatMessage message |> Html.text ]


formatChatMessage : ChatMessage -> String
formatChatMessage message =
    case message.chatType of
        Incoming ->
            "Them: " ++ message.content

        Outgoing ->
            "You: " ++ message.content
