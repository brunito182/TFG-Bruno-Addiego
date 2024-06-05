function paraula_correcta = jaccard(paraula)

% Llegir la llista de paraules
taula = readtable("palabras.txt");

distancia_minima = inf;
distancia = 0;
paraula_correcta = '';

for i = 1:size(taula,1)
    % Calcula el num de caràcters comuns (intersecció)
    interseccio = numel(intersect(paraula, taula.Palabras{i}));

    % Calcula el num de caràcters únics (unió)
    uni = numel(union(paraula, taula.Palabras{i}));

    % Calcula la distància de Jaccard i troba la distància mínima
    distancia = 1 - interseccio/uni;
    if distancia < distancia_minima
        distancia_minima = distancia;
        paraula_correcta = taula.Palabras{i};
    end
end
