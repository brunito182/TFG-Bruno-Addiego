function audioOut = preprocessat(audioIn)

[audio, fs] = audioread(audioIn);

%Conversió a mono
audio = audio(:,1);

fs_nova = 44100; %Freq. de mostreig
resample(audio,fs_nova, fs); %Actualitza la freq. de mostreig

%Elimina silencis
audio = normalize(audio, "range");
audio = normalize(audio, "center");

for i=1:length(audio)
    if -0.05 < audio(i) && audio(i) <= 0.05
        audio(i) = 0;
    end
end

audioOut = audio;