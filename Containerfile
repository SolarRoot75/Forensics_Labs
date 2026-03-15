# ==============================================================================
# FORENSICS LAB - CLI CONTAINER
# ==============================================================================
# Utilisation de la version slim pour réduire la surface d'attaque
FROM docker.io/library/debian:stable-slim

LABEL maintainer="Forensics Lab Analyst"
LABEL description="Environnement Forensics 100% CLI pour l'analyse mémoire, disque, fichiers et réseau."

# Variables d'environnement pour éviter les prompts bloquants lors du build
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# ==============================================================================
# 1. DÉPENDANCES DE BASE & SYSTÈME
# ==============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    wget \
    curl \
    unzip \
    tar \
    file \
    jq \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# 2. ANALYSE D'IMAGES DISQUES & SYSTÈMES DE FICHIERS
# ==============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    sleuthkit \
    testdisk \
    xxd \
    hashdeep \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# 3. EXTRACTION, STÉGANOGRAPHIE & ANALYSE DE FICHIERS (IMAGE, ETC..)
# ==============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    binwalk \
    foremost \
    libimage-exiftool-perl \
    steghide \
    pngcheck \
    zbar-tools \
    yara \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# INSTALLATION DE RADARE2 (Depuis les sources)
WORKDIR /opt
RUN git clone https://github.com/radareorg/radare2 \
    && cd radare2 \
    && sys/install.sh

# ==============================================================================
# 4. ANALYSE RÉSEAU (PCAP)
# ==============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    tshark \
    tcpdump \
    ngrep \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# 5. ANALYSE DE LA MÉMOIRE (VOLATILITY)
# ==============================================================================
# Création de l'environnement virtuel Python isolé
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

WORKDIR /opt

# INSTALLATION DE VOLATILITY 3
RUN git clone https://github.com/volatilityfoundation/volatility3.git \
    && cd volatility3 \
    && pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --no-cache-dir ".[full]" \
    && ln -s /opt/volatility3/vol.py /usr/local/bin/vol

ENV VOLATILITY_SYMBOL_DIR=/opt/volatility3/volatility3/symbols

# INSTALLATION DE VOLATILITY 2 (Standalone - CLI Uniquement)
RUN wget -q http://downloads.volatilityfoundation.org/releases/2.6/volatility_2.6_lin64_standalone.zip \
    && unzip -q volatility_2.6_lin64_standalone.zip \
    && ln -s /opt/volatility_2.6_lin64_standalone/volatility_2.6_lin64_standalone /usr/local/bin/vol2 \
    && rm volatility_2.6_lin64_standalone.zip

# ==============================================================================
# 6. CONFIGURATION DE L'ESPACE DE TRAVAIL
# ==============================================================================
RUN mkdir -p /work/evidence /work/output

WORKDIR /work

CMD ["/bin/bash"]