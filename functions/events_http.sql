CREATE OR REPLACE FUNCTION public.events_http_headers(event_id uuid, bot bot_members)
    RETURNS http_header[] AS
$$
BEGIN
    return ARRAY [
        http_header('X-Version'::varchar, 'v1'::varchar),
        http_header('X-Bot-ID'::varchar, bot.id::varchar),
        http_header('X-Event-ID'::varchar, event_id::varchar)
        ];
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.events_http_send_message_event(event_id uuid, bot bot_members, message messages)
    RETURNS http_response AS
$$
DECLARE
    res     http_response;
    headers http_header[];
BEGIN
    SELECT
           public.events_http_headers(event_id, bot)
    INTO headers;

    SELECT *
        INTO res
        FROM http((
                   'POST',
                   bot.interactions_url,
                   headers,
                   'application/json',
                   '{"type": 1}'
                   --(('{"type": 1, "t":"' || event.event_type::varchar || '"}')::jsonb || jsonb_build_object('data', public.events_json_encode_message(message))) #>> '{}'
            )::http_request
        );

    RETURN res;
END ;
$$ LANGUAGE plpgsql;