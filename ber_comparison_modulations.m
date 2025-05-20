
N = 1e6;
EbN0_dB = 0:1:10;
ber1 = zeros(size(EbN0_dB));
ber2 = zeros(size(EbN0_dB));
ber3 = zeros(size(EbN0_dB));
ber4 = zeros(size(EbN0_dB));
ber5 = zeros(size(EbN0_dB));

for i = 1:length(EbN0_dB)
    EbN0 = 10.^(EbN0_dB(i)/10);

    % BPSK
    b = randi([0 1], 1, N);
    s = 2*b - 1;
    n = sqrt(1/(2*EbN0)) * randn(1, N);
    r = s + n;
    br = r > 0;
    ber1(i) = sum(b ~= br) / N;

    % QPSK
    bq = randi([0 1], 1, 2*N);
    sq = (2*bq(1:2:end)-1) + 1j*(2*bq(2:2:end)-1);
    nq = (randn(1,N) + 1j*randn(1,N))/sqrt(2*EbN0);
    rq = sq + nq;
    bi = real(rq) > 0;
    bq_ = imag(rq) > 0;
    ber2(i) = (sum(bq(1:2:end) ~= bi) + sum(bq(2:2:end) ~= bq_)) / (2*N);

    % 8-PSK
    bp = randi([0 1], 1, 3*N);
    m = bp(1:3:end)*4 + bp(2:3:end)*2 + bp(3:3:end);
    a = 2*pi*m/8;
    sp = exp(1j*a);
    np = (randn(1,N) + 1j*randn(1,N))/sqrt(2*EbN0);
    rp = sp + np;
    ang = mod(angle(rp),2*pi);
    mk = mod(round(ang/(2*pi/8)),8);
    bp_ = zeros(3,N);
    for j = 1:3
        bp_(j,:) = bitget(mk,4-j+1);
    end
    ber3(i) = sum(bp ~= bp_(:)')/(3*N);

    % 16-QAM
    bq1 = randi([0 1], 1, 4*N);
    d = reshape(bq1, 4, []).';
    I = 2*(2*d(:,1) + d(:,2))-3;
    Q = 2*(2*d(:,3) + d(:,4))-3;
    sqam = I + 1j*Q;
    nqam = (randn(1,N) + 1j*randn(1,N))/sqrt(10*EbN0);
    rqam = sqam.' + nqam;
    Ik = 2*round((real(rqam)+3)/2)-3;
    Qk = 2*round((imag(rqam)+3)/2)-3;
    b1 = (Ik >= 0);
    b2 = (abs(Ik) == 1);
    b3 = (Qk >= 0);
    b4 = (abs(Qk) == 1);
    bq1_ = [b1 b2 b3 b4]';
    ber4(i) = sum(bq1 ~= bq1_(:)')/(4*N);

    % 2-FSK
    bf = randi([0 1],1,N);
    s0 = (bf == 0);
    s1 = (bf == 1);
    nf = sqrt(1/(2*EbN0)) * randn(1, N);
    rf = s1 - s0 + nf;
    bfr = rf > 0;
    ber5(i) = sum(bf ~= bfr) / N;
end

semilogy(EbN0_dB, ber1, 'o-'); hold on;
semilogy(EbN0_dB, ber2, 's-');
semilogy(EbN0_dB, ber3, '^-');
semilogy(EbN0_dB, ber4, 'x-');
semilogy(EbN0_dB, ber5, 'd-');
xlabel('E_b/N_0 (dB)');
ylabel('BER');
legend('BPSK','QPSK','8-PSK','16-QAM','2-FSK');
grid on;
title('BER Performance Comparison');
