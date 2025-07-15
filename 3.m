% Wczytanie danych z pliku CSV
filename = 'ok_pomiar_niuniu_2.csv';
fid = fopen(filename, 'r');
lines = textscan(fid, '%s', 'Delimiter', '\n'); fclose(fid);
lines = lines{1};


czas = []; ul = []; un = [];

for i = 2:length(lines)
    line = strrep(lines{i}, ',', '.');        % zamiana przecinków na kropki (jeśli PL format)
    tokens = strsplit(line, ';');             % separator CSV: średnik
    if length(tokens) >= 3
        t = str2double(tokens{1});            % kolumna A – czas
        l = str2double(tokens{2});            % kolumna B – ul (przedramię)
        n = str2double(tokens{3});            % kolumna C – un (nadgarstek)
        if ~isnan(t) && ~isnan(l) && ~isnan(n)
            czas(end+1) = t;
            ul(end+1) = l;
            un(end+1) = n;
        end
    end
end

% Konwersja do kolumn
czas = czas';
ul = ul';
un = un';

% Parametry
fs = 1 / mean(diff(czas)); % częstotliwość próbkowania
N_values = [5]; % szerokości okna
idx = czas <= 25;

% Filtracja
for i = 1:length(N_values)
    N = N_values(i);
    
    % Filtr ze średnią kroczącą 
    un_ma = filter(ones(1, N)/N, 1, un);
    
    % Filtr ze średnią kroczącą 
    ul_ma = filter(ones(1, N)/N, 1, ul);
    
    % Wykresy
    figure;
    plot(czas(idx), un_ma(idx), 'b-', 'LineWidth', 2); hold on;
    plot(czas(idx), ul_ma(idx), 'r-', 'LineWidth', 2);
    xlabel('Czas [s]');
    ylabel('Amplituda');
    legend('Nadgarstek (un)', 'Przedramię (ul)');
    grid on;
end
