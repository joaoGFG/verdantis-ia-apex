DECLARE
    l_retorno_json CLOB;
    l_payload      CLOB;
    l_api_key      VARCHAR2(100) := 'apikey';
    l_url          VARCHAR2(1000);
    l_prompt       VARCHAR2(32767);
    l_texto_gerado VARCHAR2(32767);
BEGIN
    -- 1. Puxa os dados que o usuário digitou na tela (P2_DADOS_LOTE)
    l_prompt := 'Aja como um auditor agrícola. Gere um atestado de qualidade muito curto e comercial com base nestes dados: ' || :P2_DADOS_LOTE;
    
    -- 2. Monta o JSON
    l_payload := '{"contents":[{"parts":[{"text":"' || l_prompt || '"}]}]}';
    
    -- 3. URL do Endpoint
    l_url := 'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=' || l_api_key;

    -- 4. Headers
    apex_web_service.g_request_headers(1).name := 'Content-Type';
    apex_web_service.g_request_headers(1).value := 'application/json';

    -- 5. Disparamos o POST
    l_retorno_json := apex_web_service.make_rest_request(
        p_url         => l_url,
        p_http_method => 'POST',
        p_body        => l_payload
    );

    -- 6. Extrai apenas o texto gerado pela IA
    apex_json.parse(l_retorno_json);
    l_texto_gerado := apex_json.get_varchar2(p_path => 'candidates[%d].content.parts[%d].text', p0 => 1, p1 => 1);

    -- 7. Joga o resultado limpo no campo da tela para o usuário ver
    :P2_RESPOSTA_IA := l_texto_gerado;
END;