function [I_signal, Q_signal] = transmit_ble_image(input_image_path, SNR_dB)
    % Input validation
    if nargin < 2
        SNR_dB = 15; % Default SNR value
    end
    
    % Load and validate image
    try
        input_image = imread(input_image_path);
    catch
        error('Unable to load image. Please check the file path.');
    end
    
    % Create figure for visualization
    figure('Name', 'BLE Transmission Stages');
    
    % Stage 1: Image Preprocessing
    fprintf('Stage 1: Image Preprocessing\n');
    if size(input_image, 3) == 3
        img_gray = rgb2gray(input_image);
    else
        img_gray = input_image;
    end
    

    
    subplot(3, 2, 1);
    imshow(img_gray);
    title('Grayscale Image');
    
    % Stage 2: Binary Conversion
    fprintf('Stage 2: Binary Conversion\n');
    binary_data = image_to_binary(img_gray);
    
    subplot(3, 2, 2);
    plot_binary_sample(binary_data(1:100), 'Initial Binary Data');
    
    % Stage 3: Packetization
    fprintf('Stage 3: Packetization\n');
    packet_size = 256;
    packets = packetize_data(binary_data, packet_size);
    
    subplot(3, 2, 3);
    visualize_packets(packets(1:2, :), 'Packetized Data Structure');
    
    % Stage 4: Channel Coding (Hamming)
    fprintf('Stage 4: Channel Coding\n');
    encoded_data = apply_hamming_coding(binary_data);
    
    subplot(3, 2, 4);
    plot_binary_sample(encoded_data(1:100), 'Hamming Encoded Data');
    
    % Stage 5: Data Whitening
    fprintf('Stage 5: Data Whitening\n');
    whitened_data = apply_data_whitening(encoded_data);
    
    subplot(3, 2, 5);
    plot_binary_sample(whitened_data(1:100), 'Whitened Data');
    
    % Stage 6: GFSK Modulation
    fprintf('Stage 6: GFSK Modulation\n');
    samples_per_bit = 8;
    modulation_index = 0.5;
    [I_signal, Q_signal] = apply_gfsk_modulation(binary_data, modulation_index, samples_per_bit);
    
    
    % Plot constellation
    subplot(3, 2, 6);
    plot_constellation(I_signal(1:1000), Q_signal(1:1000));
end

function binary_data = image_to_binary(img)

    img_vector = img(:);
    
    % Initialize binary array (8 bits per pixel)
    binary_data = false(1, numel(img) * 8);
    
    % Convert each pixel to 8 bits
    for i = 1:numel(img)
        % Get bit representation of current pixel
        pixel_bits = bitget(img_vector(i), 8:-1:1);
        % Store in binary array
        binary_data((i-1)*8 + 1 : i*8) = pixel_bits;
    end
end

function packets = packetize_data(data, packet_size)
    % Add preamble and access address to each packet
    preamble = [1 0 1 0 1 0 1 0];  % Standard BLE preamble
    access_address = randi([0 1], 1, 32);  % Random 32-bit access address
    
    data_bits_per_packet = packet_size * 8;
    num_packets = ceil(length(data) / data_bits_per_packet);
    
    % Initialize packets array
    header_size = length(preamble) + length(access_address);
    packet_total_size = header_size + data_bits_per_packet;
    packets = zeros(num_packets, packet_total_size);
    
    for i = 1:num_packets
        % Add header
        packets(i, 1:length(preamble)) = preamble;
        packets(i, length(preamble)+1:header_size) = access_address;
        
        % Add data
        start_idx = (i-1) * data_bits_per_packet + 1;
        end_idx = min(i * data_bits_per_packet, length(data));
        packet_data = data(start_idx:end_idx);
        
        if length(packet_data) < data_bits_per_packet
            packet_data = [packet_data zeros(1, data_bits_per_packet - length(packet_data))];
        end
        
        packets(i, header_size+1:end) = packet_data;
    end
end

function encoded = apply_hamming_coding(data)
    % Add interleaving to prevent burst errors
    G = [1 1 1 0 1 0 0;
         1 1 0 1 0 1 0;
         1 0 1 1 0 0 1;
         0 1 1 1 0 0 0];
    
    % Pad data to multiple of 4
    pad = mod(4-mod(length(data),4),4);
    data = [data zeros(1,pad)];
    
    % Encode with interleaving
    encoded = [];
    for i = 1:4:length(data)
        block = data(i:i+3);
        coded_block = mod(block*G,2);
        % Add block to encoded data with interleaving
        if i > 1
            % Interleave with previous block
            coded_block = circshift(coded_block, mod(i,3));
        end
        encoded = [encoded coded_block];
    end
end

function whitened = apply_data_whitening(data)
    % Use a better initial state and longer LFSR
    lfsr = [1 1 0 1 0 1 1];  % Changed initial state
    seq_len = length(data);
    whitening_seq = zeros(1, seq_len);
    
    % Generate more random whitening sequence
    for i = 1:seq_len
        % Use more taps for better randomization
        whitening_seq(i) = lfsr(7);
        new_bit = xor(xor(lfsr(7), lfsr(4)), xor(lfsr(2), lfsr(1)));
        lfsr = [new_bit lfsr(1:6)];
    end
    
    whitened = xor(data, whitening_seq);
end

function [I_signal, Q_signal] = apply_gfsk_modulation(data, h_index, samples_per_bit)
    % Upsample data
    upsampled = zeros(1, length(data) * samples_per_bit);
    for i = 1:length(data)
        upsampled((i-1)*samples_per_bit + 1 : i*samples_per_bit) = 2*data(i) - 1;
    end
    
    % Design Gaussian filter
    BT = 0.5;  % Standard BLE bandwidth-time product
    span = 4;  % Filter span in symbols
    t = (-span/2:1/samples_per_bit:span/2);
    alpha = sqrt(log(2)/(2*(BT^2)));
    gaussian_filter = exp(-(alpha^2 * t.^2));
    gaussian_filter = gaussian_filter / sum(gaussian_filter);
    
    % Apply Gaussian filter
    filtered_data = conv(upsampled, gaussian_filter, 'same');
    
    % Generate phase
    phase = cumsum(filtered_data) * pi * h_index;
    
    % Generate I/Q components
    I_signal = cos(phase);
    Q_signal = sin(phase);
end

function plot_binary_sample(data, title_str)
    stem(1:length(data), data, 'LineWidth', 1.5);
    title(title_str);
    xlabel('Bit Index');
    ylabel('Bit Value');
    ylim([-0.2 1.2]);
    grid on;
end

function visualize_packets(packets, title_str)
    imagesc(packets);
    title(title_str);
    xlabel('Bit Position');
    ylabel('Packet Number');
    colormap(gray);
    colorbar;
end

function plot_iq_components(I, Q)
    plot(1:length(I), I, 'b-', 1:length(Q), Q, 'r-', 'LineWidth', 1.5);
    title('I/Q Components');
    xlabel('Sample Index');
    ylabel('Amplitude');
    legend('I', 'Q');
    grid on;
end

function plot_constellation(I, Q)
    scatter(I, Q, 10, 'filled');
    title('Signal Constellation');
    xlabel('I');
    ylabel('Q');
    grid on;
    axis equal;
end