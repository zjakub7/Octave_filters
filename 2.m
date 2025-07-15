% Wczytanie danych z pliku CSV 
filename = 'ok_pomiar_niuniu_2.csv';
fid = fopen(filename, 'r');
lines = textscan(fid, '%s', 'Delimiter', '\n'); fclose(fid);
lines = lines{1};

% Inicjalizacja wektorów
czas = []; ul = []; un = [];

% Parsowanie danych — pomijamy nagłówek
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

% Konwersja do wektorów kolumnowych
czas = czas';
ul = ul';
un = un';

% Parametry filtru i testy
fs = 1 / mean(diff(czas)); % częstotliwość próbkowania
T_values = [0.05]; % testowane wartości T

% Ograniczenie wykresu do 25 s
idx = czas <= 10;

% Wykresy dla każdej wartości T
for i = 1:length(T_values)
    T = T_values(i);
    alpha = (1/fs) / (T + (1/fs));

    % Filtracja dolnoprzepustowa I rzędu 
    un_lp = zeros(size(un));
    un_lp(1) = un(1);
    for n = 2:length(un)
        un_lp(n) = alpha * un(n) + (1 - alpha) * un_lp(n-1);
    end

    ul_lp = zeros(size(ul));
    ul_lp(1) = ul(1);
    for n = 2:length(ul)
        ul_lp(n) = alpha * ul(n) + (1 - alpha) * ul_lp(n-1);
    end

    % Wykres
    figure;
    plot(czas(idx), un_lp(idx), 'b-', 'LineWidth', 2); hold on;
    plot(czas(idx), ul_lp(idx), 'r-', 'LineWidth', 2);
    xlabel('Czas [s]');
    ylabel('Amplituda');
    legend('Nadgarstek (un)', 'Przedramię (ul)');
    grid on;
end
