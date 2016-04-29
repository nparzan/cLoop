# cLoop

cLoop is an awesome  closed loop **EEG-tDCS stimulator**.

## Modules

1. Starstim Device (Neuroelectrics) - capable of registering EEG activity and transmitting tDCS stimulus
2. MATLAB Client - Communication with the Starstim Device is conducted over MATLAB using a dedicated API
3. PHP+SQL Server - Log activity during sessions, store relevant information regarding the relation between activity and stimulus
4. Machine Learning - Optimize stimulus relative to EEG activity and conduct ongoing optimization of process using regression models

## Motivation

It has been shown that many cognitive tasks can be improved via tDCS stimulation. However, in past studies a standard stimulus has been used for each task.
Using a closed-loop model, we can determine whether past stimuli have been beneficial, and if not, try to find a more suiting stimulus.

## License

This SW is proud to hold a WTFPL License.
