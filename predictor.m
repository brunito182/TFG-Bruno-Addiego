function [palabra] = predictor(audioIn)

%Carrega la xarxa
xarxa = load("xarxa_entrenada.mat");

%Aplica la funció de preprocessat
audio = preprocessat(audioIn);

fs = 44100;
paraula = '';
fonema_anterior = '';

%Definir quines característiques s'extrauran dels àudios
afe = audioFeatureExtractor('mfcc', true, 'mfccDelta', true, 'mfccDeltaDelta', true);

files_obj = 39; %Num. de files fins les quals es farà el zero padding

% Detectar segments on hi ha parla
segments = detectSpeech(audio, fs);

%% Inici del loop
for i = 1:size(segments, 1)
    % Obtenir els índexs inicial i final del segment
    start_idx = segments(i, 1);
    end_idx = segments(i, 2);
    
    % Calcular la duración del segmento de habla
    durada_segment = (end_idx - start_idx + 1);
    
    % Ajustar el tamaño de la ventana dinámicamente según la duración del segmento
    finestra = round(durada_segment*0.3);  % Ajusta este factor según sea necesario
    overlap = round(finestra * 0.5);  % Superposición del 10%
    pas = finestra - overlap;

    ham = hamming(finestra);
    
    % Itera sobre les finestres en cada segment
    for j = start_idx:pas:(end_idx - finestra + 1)

        % Extreure el segment d'àudio
        segment_audio = audio(j:j + finestra - 1);

        segment_audio = segment_audio .* ham;

        spect = extract(afe, segment_audio);
        % Verificar que la matriu d'MFCC no estigui buida i fer zeropadding
        if ~isempty(spect)
            if size(spect, 1) < files_obj
                spect = padarray(spect, files_obj - size(spect, 1), 0, 'post');
            elseif size(spect, 1) > files_obj
                spect = spect(1:files_obj, :);
            end
            spect = normalize(spect, "range");
            spect = normalize(spect, "center");
            fonema = classify(xarxa.xarxa1, spect);

            % Afegir fonema a l'string si no és igual que el fonema anterior
            if isempty(paraula) || fonema ~= fonema_anterior
                paraula = string(fonema) + paraula;
                fonema_anterior = fonema;
            end
        end
    end
    
    % Processar l'últim segment de l'àudio si no ha entrat en la iteració
    if end_idx > j

        %El loop es torna a aplicar igual que abans
        segment_audio = audio(end_idx - finestra + 1:end_idx);
        segment_audio = segment_audio .* ham;

        spect = extract(afe, segment_audio);
        if ~isempty(spect)
            if size(spect, 1) < files_obj
                spect = padarray(spect, files_obj - size(spect, 1), 0, 'post');
            elseif size(spect, 1) > files_obj
                spect = spect(1:files_obj, :);
            end
            spect = normalize(spect, "range");
            spect = normalize(spect, "center");
            fonema = classify(xarxa.xarxa1, spect);

            if isempty(paraula) || fonema ~= fonema_anterior
                paraula = string(fonema) + paraula;
                fonema_anterior = fonema;
            end
        end
    end
end

palabra = jaccard(char(paraula));

end
