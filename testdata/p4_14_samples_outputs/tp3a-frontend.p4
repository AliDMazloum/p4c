struct Version {
    bit<8> major;
    bit<8> minor;
}

error {
    NoError,
    PacketTooShort,
    NoMatch,
    EmptyStack,
    FullStack,
    OverwritingHeader
}

extern packet_in {
    void extract<T>(out T hdr);
    void extract<T>(out T variableSizeHeader, in bit<32> sizeInBits);
    T lookahead<T>();
    void advance(in bit<32> sizeInBits);
    bit<32> length();
}

extern packet_out {
    void emit<T>(in T hdr);
}

action NoAction() {
}
match_kind {
    exact,
    ternary,
    lpm
}

match_kind {
    range,
    selector
}

struct standard_metadata_t {
    bit<9>  ingress_port;
    bit<9>  egress_spec;
    bit<9>  egress_port;
    bit<32> clone_spec;
    bit<32> instance_type;
    bit<1>  drop;
    bit<16> recirculate_port;
    bit<32> packet_length;
}

extern Checksum16 {
    bit<16> get<D>(in D data);
}

enum CounterType {
    packets,
    bytes,
    packets_and_bytes
}

extern counter {
    counter(bit<32> size, CounterType type);
    void count(in bit<32> index);
}

extern direct_counter {
    direct_counter(CounterType type);
}

extern meter {
    meter(bit<32> size, CounterType type);
    void execute_meter<T>(in bit<32> index, out T result);
}

extern direct_meter<T> {
    direct_meter(CounterType type);
    void read(out T result);
}

extern register<T> {
    register(bit<32> size);
    void read(out T result, in bit<32> index);
    void write(in bit<32> index, in T value);
}

extern action_profile {
    action_profile(bit<32> size);
}

enum HashAlgorithm {
    crc32,
    crc16,
    random,
    identity
}

extern action_selector {
    action_selector(HashAlgorithm algorithm, bit<32> size, bit<32> outputWidth);
}

parser Parser<H, M>(packet_in b, out H parsedHdr, inout M meta, inout standard_metadata_t standard_metadata);
control VerifyChecksum<H, M>(in H hdr, inout M meta, inout standard_metadata_t standard_metadata);
control Ingress<H, M>(inout H hdr, inout M meta, inout standard_metadata_t standard_metadata);
control Egress<H, M>(inout H hdr, inout M meta, inout standard_metadata_t standard_metadata);
control ComputeCkecksum<H, M>(inout H hdr, inout M meta, inout standard_metadata_t standard_metadata);
control Deparser<H>(packet_out b, in H hdr);
package V1Switch<H, M>(Parser<H, M> p, VerifyChecksum<H, M> vr, Ingress<H, M> ig, Egress<H, M> eg, ComputeCkecksum<H, M> ck, Deparser<H> dep);
header data_t {
    bit<32> f1;
    bit<32> f2;
    bit<32> f3;
    bit<32> f4;
    bit<32> b1;
    bit<32> b2;
    bit<32> b3;
    bit<32> b4;
}

struct metadata {
}

struct headers {
    @name("data") 
    data_t data;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("start") state start {
        packet.extract<data_t>(hdr.data);
        transition accept;
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("setf1") action setf1(bit<32> val) {
        hdr.data.f1 = val;
    }
    @name("noop") action noop() {
    }
    @name("setb4") action setb4(bit<32> val) {
        hdr.data.b4 = val;
    }
    @name("setb1") action setb1(bit<32> val) {
        hdr.data.b1 = val;
    }
    @name("E1") table E1() {
        actions = {
            setf1();
            noop();
            NoAction();
        }
        key = {
            hdr.data.f2: ternary;
        }
        default_action = NoAction();
    }
    @name("E2") table E2() {
        actions = {
            setb4();
            noop();
            NoAction();
        }
        key = {
            hdr.data.b1: ternary;
        }
        default_action = NoAction();
    }
    @name("EA") table EA() {
        actions = {
            setb1();
            noop();
            NoAction();
        }
        key = {
            hdr.data.f3: ternary;
        }
        default_action = NoAction();
    }
    @name("EB") table EB() {
        actions = {
            setb1();
            noop();
            NoAction();
        }
        key = {
            hdr.data.f4: ternary;
        }
        default_action = NoAction();
    }
    apply {
        E1.apply();
        if (hdr.data.f1 == 32w0) 
            EA.apply();
        else 
            EB.apply();
        E2.apply();
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("setb1") action setb1(bit<32> val) {
        hdr.data.b1 = val;
    }
    @name("noop") action noop() {
    }
    @name("setb3") action setb3(bit<32> val) {
        hdr.data.b3 = val;
    }
    @name("setb2") action setb2(bit<32> val) {
        hdr.data.b2 = val;
    }
    @name("setb4") action setb4(bit<32> val) {
        hdr.data.b4 = val;
    }
    @name("A1") table A1() {
        actions = {
            setb1();
            noop();
            NoAction();
        }
        key = {
            hdr.data.f1: ternary;
        }
        default_action = NoAction();
    }
    @name("A2") table A2() {
        actions = {
            setb3();
            noop();
            NoAction();
        }
        key = {
            hdr.data.b1: ternary;
        }
        default_action = NoAction();
    }
    @name("A3") table A3() {
        actions = {
            setb1();
            noop();
            NoAction();
        }
        key = {
            hdr.data.b3: ternary;
        }
        default_action = NoAction();
    }
    @name("B1") table B1() {
        actions = {
            setb2();
            noop();
            NoAction();
        }
        key = {
            hdr.data.f2: ternary;
        }
        default_action = NoAction();
    }
    @name("B2") table B2() {
        actions = {
            setb4();
            noop();
            NoAction();
        }
        key = {
            hdr.data.b2: ternary;
        }
        default_action = NoAction();
    }
    apply {
        if (hdr.data.b1 == 32w0) {
            A1.apply();
            A2.apply();
            A3.apply();
        }
        B1.apply();
        B2.apply();
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit<data_t>(hdr.data);
    }
}

control verifyChecksum(in headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

V1Switch<headers, metadata>(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;
