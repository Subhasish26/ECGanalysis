clear; clc; close all;

%Load the ECG data (.mat file) of the patient
    load ecg3.mat;

%Plot the patient's ECG and add labels
figure();
plot(time, ecg);
legend("ECG data", 'fontSize', 11);
title("ECG Signal",'fontSize', 14);
xlabel("Time(seconds)",'fontSize', 12);
ylabel('Voltage(millivolts)', 'fontSize', 12);
ylim([-0.4,1.2]);
xlim([0,5]);

% Create an array containing arrays with indicies of each peak
for i = 1:5
    Index_Peak(i) = {find(marker==i)};
end

%Add the peak markers to the ECG graph
markerAtributes= ["+", "d", "o", "*", "x";
"Peak P","Peak Q","Peak R","Peak S","Peak T"];
hold on;

for i = 1:5
    plot(time(Index_Peak{i}),ecg(Index_Peak{i}),markerAtributes(1,i),'MarkerSize', 11 ,'DisplayName', markerAtributes(2,i),'lineWidth', 1.5);
end
    
%% P wave Analysis (Heart rate and variation)

%Calculate the period of Heart Beat and then find Heart Rate
Period = diff(time(Index_Peak{1}));
Avg_Heart_Rate = 60 / (sum(Period) / length(Period));
Heart_Rate = 60./Period;

%Compare the Heart Rate and perform diagnosis 
if Avg_Heart_Rate < 60
    Diag_Heart_Rate="Sinus Bradycardia";
elseif 60 <= Avg_Heart_Rate && Avg_Heart_Rate <= 100
    Diag_Heart_Rate = "Normal Rate";
else
    Diag_Heart_Rate = "Sinus Tachycardia";
end

%Find the maximum variation in Heart Rate
Max_Var_Heart_Rate = 0;
for i= 2: length(Heart_Rate)
    Possible_Maximum = abs(1 - (Heart_Rate(i)/Heart_Rate(i-1)));
    if Possible_Maximum > Max_Var_Heart_Rate
        Max_Var_Heart_Rate = Possible_Maximum;
    end
end

%Compare the Heart Rate from the acceptable range and perform diagnosis
if Max_Var_Heart_Rate < 1.1   
    Diag_Variation = " Less than 10% - Normal";
elseif Max_Var_Heart_Rate > 1.1
    Diag_Variation = "Greater than 10% - Sinus Arrhythmia";
end

%% PR Interval Analysis (0.12 - 0.20 s)
PR_Interval = findInterval(Index_Peak{1}, Index_Peak{3}, time);
Avg_PR_Interval = sum(PR_Interval) / length(PR_Interval);
Diag_PR_Interval = "PR Interval Normal";

%Compare PR interval to normal and perform diagnosis
if Avg_PR_Interval>0.20
    Diag_PR_Interval = "Long, can be first degree heart block and trifascular block ";
elseif Avg_PR_Interval<0.12
    Diag_PR_Interval = "Short, can be Wolff Parkinson White Syndrome or Lown Ganong Levine Syndrome ";
end

%% QRS Interval Analysis (<0.12s)

%Find each QRS interval and calculate the average QRS interval
QRS_Interval = findInterval(Index_Peak{2}, Index_Peak{4}, time);
Avg_QRS_Interval = sum(QRS_Interval)/length(QRS_Interval);

%Compare the QRS duration to normal and perform diagnosis
Diag_QRS_Interval = "Normal QRS Duration";
if Avg_QRS_Interval > 0.12
    Diag_QRS_Interval = "Long, can be right or left bundle branch block, Hyperkalaemia";
end

%% QT Interval Analysis (<0.48s)

% Measure the QT interval from the START of Q wave to END of T wave. However for rough calculations, the points are shifted to the the peak of the P wave and the T wave.
QT_Interval = findInterval(Index_Peak{1}, Index_Peak{5}, time);
QT_Interval_Corrected = QT_Interval./sqrt(Period);
Avg_QTc = sum(QT_Interval_Corrected) / length(QT_Interval_Corrected);

%Compares QTC interval to normal and creates diagnosis
    Diag_QTc_Interval = "Normal QTC Interval";
if(Avg_QTc>0.48)
    Diag_QTc_Interval = "High, can be Myocardial Infarction or Subarachnoid Haemorrhage (SAH)";
end

%% Informs user of possible heart conditions
disp(" - - - - - - - - - - - - ECG REPORT - - - - - - - - - - - - ")
disp("Patient ECG Analysis :")
disp("Heart rate: " + round(Avg_Heart_Rate) + "bpm - " + Diag_Heart_Rate )
disp("Variation in Heart Rate: "+ Diag_Variation)
disp("PR Interval: " + round(Avg_PR_Interval,2) + "seconds - " + Diag_PR_Interval)
disp("QRS Interval: " + round(Avg_QRS_Interval,2)+ "seconds - " + Diag_QRS_Interval)
disp("QT Interval: "+ round(Avg_QTc,2) + "seconds - " + Diag_QTc_Interval)
disp(" - - - - - - - - - - - END OF REPORT  - - - - - - - - - - - ")

%% Funtion that returns array with interval between peaks
function f = findInterval(first, second, time)
    start = 1;
    last = 0;

    %Check if the second peak comes before the first peak at the start
    if first(1)>second(1)
        start = 2;
    end
    
    %Check if the first peak appears at the end of the data without the second peak after
    if first(end)>second(end)
        last = 1;
    end
    
    %Return the array with interval between each set of peaks.
    f = time(second(start:end)) - time(first(1:end-last));
end